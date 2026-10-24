#!/usr/bin/env python3
"""Content pipeline: turns the lesson source below into the structured catalog the app renders.

- Records narration with the macOS `say` voice (stand-in for the studio recordings the
  content team provides) and encodes it to AAC (.m4a).
- Per-word clips for tap-to-hear words and phonemes.
- One clip per reading passage, built by joining word clips, so each word gets an exact
  start/end timestamp. The app highlights words from these timings (karaoke style)
  instead of loading hundreds of tiny files during reading.
- Writes assets/content/catalog.json. The same JSON shape maps 1:1 to Firestore
  documents (see lib/data/repositories/firestore_content_repository.dart).

Run: python3 tool/build_content.py
"""
import json
import os
import re
import subprocess
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO = os.path.join(ROOT, "assets", "audio")
OUT = os.path.join(ROOT, "assets", "content", "catalog.json")
VOICE = "Samantha"
RATE = "150"
GAP_MS = 140

os.makedirs(AUDIO, exist_ok=True)
os.makedirs(os.path.dirname(OUT), exist_ok=True)
TMP = tempfile.mkdtemp()


def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def duration_ms(path):
    out = subprocess.check_output([
        "ffprobe", "-v", "error", "-show_entries", "format=duration",
        "-of", "default=nw=1:nk=1", path]).decode().strip()
    return int(float(out) * 1000)


def say_wav(text, name, rate=RATE):
    aiff = os.path.join(TMP, name + ".aiff")
    wav = os.path.join(TMP, name + ".wav")
    subprocess.check_call(["say", "-v", VOICE, "-r", rate, "-o", aiff, text])
    # trim leading/trailing silence so word timings are tight
    subprocess.check_call([
        "ffmpeg", "-y", "-loglevel", "error", "-i", aiff, "-af",
        "silenceremove=start_periods=1:start_threshold=-45dB,areverse,"
        "silenceremove=start_periods=1:start_threshold=-45dB,areverse",
        "-ar", "22050", "-ac", "1", wav])
    return wav


def to_m4a(wav, rel):
    dst = os.path.join(AUDIO, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    subprocess.check_call(["ffmpeg", "-y", "-loglevel", "error", "-i", wav,
                           "-c:a", "aac", "-b:a", "48k", dst])
    return "assets/audio/" + rel


def word_clip(word, spoken=None, rate=RATE):
    rel = f"words/{slug(word)}.m4a"
    wav = say_wav(spoken or word, "w-" + slug(word), rate)
    return to_m4a(wav, rel)


def phoneme_clip(key, spoken):
    wav = say_wav(spoken, "p-" + key, "110")
    return to_m4a(wav, f"phonemes/{key}.m4a")


def passage(pid, lines):
    """Joins per-word recordings into one passage clip and returns timed lines."""
    silence = os.path.join(TMP, "gap.wav")
    subprocess.check_call(["ffmpeg", "-y", "-loglevel", "error", "-f", "lavfi", "-i",
                           "anullsrc=r=22050:cl=mono", "-t", str(GAP_MS / 1000), silence])
    parts, timed, t = [], [], 0
    for li, line in enumerate(lines):
        words = []
        for wi, raw in enumerate(line.split()):
            clean = re.sub(r"[^A-Za-z']", "", raw)
            wav = say_wav(clean, f"{pid}-{li}-{wi}")
            d = duration_ms(wav)
            parts += [wav, silence]
            words.append({"text": raw, "startMs": t, "endMs": t + d})
            t += d + GAP_MS
        # longer pause at line end
        parts.append(silence)
        t += GAP_MS
        timed.append({"words": words})
    listfile = os.path.join(TMP, pid + ".txt")
    with open(listfile, "w") as f:
        for p in parts:
            f.write(f"file '{p}'\n")
    wav = os.path.join(TMP, pid + "-full.wav")
    subprocess.check_call(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0",
                           "-i", listfile, "-c", "copy", wav])
    return to_m4a(wav, f"passages/{pid}.m4a"), timed, t


def page_clip(pid, n, text):
    wav = say_wav(text, f"{pid}-page{n}", "140")
    return to_m4a(wav, f"stories/{pid}-{n}.m4a")


# ---------------------------------------------------------------------------------
# Lesson source (what a content editor would maintain in the CMS)
# ---------------------------------------------------------------------------------

PHONEMES = {"c": "kuh", "a": "aah", "t": "tuh", "s": "sss", "m": "mmm", "h": "huh",
            "b": "buh", "p": "puh"}

catalog = {"version": 1, "activities": [], "routines": {}, "achievements": []}


def tap_words(aid, title, category, minutes, level, skills, cover, sentence, targets, prompt,
              new=False):
    tokens = []
    for raw in sentence.split():
        clean = re.sub(r"[^A-Za-z]", "", raw).lower()
        tok = {"text": raw}
        if clean in targets:
            tok["audio"] = word_clip(clean)
            tok["phonemes"] = [{"grapheme": ch, "audio": phoneme_clip(ch, PHONEMES[ch])}
                               for ch in clean]
        tokens.append(tok)
    full = say_wav(sentence, aid + "-sentence", "135")
    catalog["activities"].append({
        "id": aid, "type": "tapWords", "title": title, "category": category,
        "minutes": minutes, "level": level, "skills": skills, "cover": cover, "isNew": new,
        "summary": f"Tap the pink words in '{sentence}' to hear each sound.",
        "payload": {"tokens": tokens, "sentenceAudio": to_m4a(full, f"sentences/{aid}.m4a"),
                    "parentPrompt": prompt}})


def letter_sound(aid, title, minutes, level, cover, letter, words, prompt, new=False):
    catalog["activities"].append({
        "id": aid, "type": "letterSound", "title": title, "category": "sounds",
        "minutes": minutes, "level": level, "skills": ["letter-sounds"], "cover": cover,
        "isNew": new, "summary": f"Meet the letter {letter} and the sound it makes.",
        "payload": {"letter": letter,
                    "letterAudio": phoneme_clip(letter, PHONEMES[letter]),
                    "words": [{"text": w, "audio": word_clip(w)} for w in words],
                    "parentPrompt": prompt}})


def read_along(aid, title, minutes, level, cover, lines, prompts, new=False):
    audio, timed, total = passage(aid, lines)
    catalog["activities"].append({
        "id": aid, "type": "readAlong", "title": title, "category": "reading",
        "minutes": minutes, "level": level, "skills": ["blending", "sight-words"],
        "cover": cover, "isNew": new, "summary": "Listen, follow the glowing words, then read it back together.",
        "payload": {"audio": audio, "durationMs": total, "lines": timed,
                    "prompts": prompts}})


def storybook(aid, title, minutes, level, cover, pages, listen, summary, new=False):
    out = []
    for i, p in enumerate(pages, 1):
        out.append({"image": p["image"], "text": p["text"], "highlight": p.get("highlight", []),
                    "coachTip": p["coach"], "audio": page_clip(aid, i, p["text"])})
    catalog["activities"].append({
        "id": aid, "type": "storybook", "title": title, "category": "stories",
        "minutes": minutes, "level": level, "skills": ["comprehension", "sight-words"],
        "cover": cover, "isNew": new, "summary": summary,
        "payload": {"wordsToListenFor": listen,
                    "beforeYouRead": "Ask Maya what she thinks Pip will find.",
                    "pages": out}})


IMG = "assets/images/"

letter_sound("letter-short-a", "Letter sound: short a", 3, 1, IMG + "thumb-short-a.jpg", "a",
             ["ant", "apple", "cat"],
             "Say the sound together, then hunt for one thing at home that starts with a.")
tap_words("tap-cat-sat", "Tap the words: The cat sat", "sounds", 3, 1, ["letter-sounds", "blending"],
          IMG + "cover-short-a.jpg", "The cat sat on a mat.", {"cat", "sat", "mat"},
          "Point to each letter as you say it. Ask: what sound does a make?")
read_along("read-map-for-sam", "Read along: A Map for Sam", 4, 2, IMG + "cover-map-for-sam.jpg",
           ["Sam has a map.", "The map is red.", "Sam and Dad go to the big tree.",
            "Is the hat in the tree?"],
           [{"afterLine": 1, "text": "Pause here. Ask Maya: what color is the map?"},
            {"afterLine": 3, "text": "Pause here. Ask Maya: where do you think the hat is?"}])
storybook("story-pip-hat", "Story time: Pip Finds a Hat", 5, 1, IMG + "cover-pip-finds-a-hat.jpg", [
    {"image": IMG + "cover-pip-finds-a-hat.jpg", "text": "Pip is a little pup.", "highlight": ["pup"],
     "coach": "Point to the word pup. Ask Maya what sound it starts with."},
    {"image": IMG + "cover-pip-small.jpg", "text": "Pip can dig and dig.", "highlight": ["dig"],
     "coach": "Dig is said twice. Let Maya read the second one."},
    {"image": IMG + "story-pip-page3.jpg", "text": "Pip sees a red hat. Is it a big hat? No, it is a little hat!",
     "highlight": ["red", "hat"], "coach": "Point to the word hat. Ask Maya to find it again on this page."},
    {"image": IMG + "cover-pip-finds-a-hat.jpg", "text": "Pip sits in the sun with his hat.",
     "highlight": ["sits", "sun"], "coach": "Sits and sun both start with s. Hiss it together: sss."},
], ["hat", "big", "sit", "red"], "A curious puppy finds a little red hat. Practice short a and i words together.")
tap_words("rhyme-with-cat", "Rhyme with Cat", "rhymes", 3, 1, ["rhyming"], IMG + "cover-rhyme-cat.jpg",
          "A cat, a hat, a bat, a mat!", {"cat", "hat", "bat", "mat"},
          "Clap once for every word that rhymes with cat.")
storybook("story-big-red-bus", "The Big Red Bus", 6, 1, IMG + "cover-big-red-bus.jpg", [
    {"image": IMG + "cover-big-red-bus.jpg", "text": "The bus is big. The bus is red.", "highlight": ["bus", "big"],
     "coach": "Run a finger under each word as Maya reads."},
    {"image": IMG + "cover-big-red-bus-2.jpg", "text": "Beep beep! The bus can go.", "highlight": ["bus"],
     "coach": "Make the beep sound together, then find the word bus."},
], ["bus", "big", "red"], "A big red bus goes beep. A first story with short u and short i words.", new=True)
letter_sound("letter-m-walk", "Letter m Walk", 2, 1, IMG + "cover-letter-m.jpg", "m",
             ["map", "mat", "mom"], "Ask Maya to spot things starting with m around your home.")
letter_sound("short-a-sounds", "Short a Sounds", 3, 1, IMG + "thumb-short-a.jpg", "a",
             ["hat", "bat", "sat"], "Stretch the middle sound: h-aaa-t.")

catalog["routines"] = {
    "just-starting": ["letter-short-a", "tap-cat-sat", "read-map-for-sam", "story-pip-hat"],
    "blending": ["tap-cat-sat", "rhyme-with-cat", "read-map-for-sam", "story-big-red-bus"],
    "reading": ["read-map-for-sam", "story-pip-hat", "story-big-red-bus", "rhyme-with-cat"],
}

catalog["achievements"] = [
    {"id": "first-story", "title": "First Story", "rule": {"stories": 1}},
    {"id": "sound-explorer", "title": "Sound Explorer", "rule": {"sounds": 3}},
    {"id": "streak-3", "title": "3-Day Streak", "rule": {"streak": 3}},
    {"id": "words-25", "title": "Word Collector", "rule": {"words": 25}},
    {"id": "bookworm", "title": "Bookworm", "rule": {"stories": 5}},
    {"id": "rhyme-time", "title": "Rhyme Time", "rule": {"rhymes": 1}},
    {"id": "early-bird", "title": "Early Bird", "rule": {"minutes": 30}},
    {"id": "streak-10", "title": "10-Day Streak", "rule": {"streak": 10}},
    {"id": "story-builder", "title": "Story Builder", "rule": {"stories": 10}},
    {"id": "words-50", "title": "50 Words", "rule": {"words": 50}},
    {"id": "read-aloud-star", "title": "Read Aloud Star", "rule": {"minutes": 120}},
    {"id": "streak-30", "title": "30-Day Streak", "rule": {"streak": 30}},
]

with open(OUT, "w") as f:
    json.dump(catalog, f, indent=2)
print(f"wrote {OUT}: {len(catalog['activities'])} activities")

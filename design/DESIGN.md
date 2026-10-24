# Hopscotch Design System

Bright, warm, playful-but-calm mobile app for parents and young children (ages 3-7) practicing reading together. Light theme. Frame 393x852 (iPhone 16/17). Keep top ~59px and bottom ~34px safe areas clear.

## Color (use ONLY these colors; no default violet or indigo, no flat neutral grey)
- Background: #FCF4F9 (pink-tinted near-white)
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows): #F8E9F2
- Accent (large fills, icons, active states, hero numerals): #FC69C3
- Accent fill (buttons/chips with WHITE labels): #CA047E, pressed #C2037A
- Accent tint (selected, chips, highlighted words): #FEE3F3 with text #8F0459
- Support (secondary data, illustrations, parent prompt cards): #B09EFA, strong series #9880FA, tint #EEE9FE with text #4B3A9C
- Text primary #1F0C18, secondary #5E4A57, tertiary #7A6673
- Border hairline #EED9E6, input/control border #B682AE
- Status: success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5
- Category colors: Sounds pink tint #FEE3F3 / #8F0459; Reading lavender #EEE9FE / #4B3A9C; Stories peach #FFEBDD / #8A3F00; Rhymes mint #DDF5EA / #166534
- Hero gradient (only surface that carries white text): #CA047E -> #6A4FD8. Soft decorative blend #FEE3F3 -> #EEE9FE never behind text.

## Typography
- Display / hero titles: Sniglet 32/700
- UI + body: Varela Round. Title 20/600, Body 16/400, Label 14/500, Caption 13/500
- Reading text for children (sentences, story text): Varela Round 24-32px, generous line height 1.4
- Only these 5 sizes plus the large reading text. Minimum text 12px (13px chips and tags, 14px safety or legal text).

## Shape, spacing, elevation
- Radius: card 24, control 16, input 12, pill 999
- 8pt spacing (4, 8, 12, 16, 24, 32), screen edge padding 20px
- Card shadow soft only: 0 1px 2px rgba(31,12,24,.04), 0 8px 24px rgba(31,12,24,.06)
- Tap targets >= 48pt (kids and parents)

## Icons
One set only: rounded outline (Lucide style), 24px, 1.75 stroke. Never mix filled and outline.

## Controls (one spec each, reused on every screen)
- Primary button: pill, 56px tall, #CA047E fill, white label; pressed #C2037A; disabled 40% opacity
- Secondary button: pill, white, 1.5px #B682AE border, #1F0C18 label
- Input: 12px radius, white, border #B682AE, focus ring #CA047E 2px, error #CE2020
- Card: 24px radius, white, soft shadow
- Chip: pill, #FEE3F3 fill, #8F0459 text, 13px
- Highlighted tappable word: #FEE3F3 rounded pill behind the word, #8F0459 bold text, small speaker icon
- Parent prompt card: #EEE9FE fill, 24px radius, small "Parent" label in #4B3A9C, body #1F0C18

## Shared components
Bottom tab bar with exactly these four tabs in this order: Today (sun icon), Library (book-open icon), Progress (trophy icon), Profile (user-round icon). Active tab: icon and label in #CA047E with a soft #FEE3F3 pill behind the icon. Inactive tabs #5E4A57. Flat white bar, hairline top border #EED9E6, safe-area bottom inset. Never rename, reorder, add or remove tabs.
Activity screens (tap words, read along, storybook) hide the tab bar and show a close X, a thin pink progress bar and a step label.

## Imagery
Real photography only (parents and young children reading, cozy homes, warm daylight); storybook pages and badges use flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Focal and gradient rules
One bold focal element per screen. Any surface with white text uses the hero gradient #CA047E -> #6A4FD8 and nothing lighter. Chips on a gradient use a dark translucent fill. Flat tab bar.

## Meaning of color
Red only for errors and destructive actions. Warnings use the warning color with an icon.

## Copy scope
Do not mention: Classroom, Teacher dashboard, Ads, Chat with strangers, Grades, Test score. No invented integrations. Child is Maya (age 5); parent is Jenna Parker.

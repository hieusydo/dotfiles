# Personal agent instructions

These are my personal rules for coding agents. They apply in all repositories.

## Hard rules

Always obey these rules.

### Technical documents

When you write a technical design document, an investigation, or a report, use
simple technical English. Follow the rules in "Simple technical English" below.

### Pull request descriptions

When you create or update a pull request description, obey these rules:

- Include these three sections. Use these exact headings, in this order:

  ```markdown
  ## Problem & Solution Overview

  ## Testing Done

  ## Notes for Reviewers
  ```

- In "Problem & Solution Overview", describe the problem and why it is
  important. Then describe how the change solves the problem.
- In "Testing Done", list the tests, commands, and manual checks that you did,
  and their results. Give the exact commands. If you did not test a part of the
  change, say so and give the reason.
- In "Notes for Reviewers", tell reviewers where to start, which parts need
  careful review, the risks, and the follow-up work. If you have no notes,
  write "None."
- Write the description in simple technical English.
- Never add a bot or AI signature to the description, for example
  "🤖 Generated with GitHub Copilot CLI" or "Generated with Claude Code". If a
  tool adds a signature automatically, remove it before you create or update
  the pull request.

### Google Docs

When you create or edit a Google Doc, use the format in "Google Docs format"
below.

## Simple technical English

Follow ASD-STE100 (Simplified Technical English) for approximately 80% of the
text. Strict compliance is not necessary. Clarity and accuracy are more
important than the rules. Break a rule only when the strict form makes the text
less clear or less accurate.

Sentences:

- Write short sentences. Use a maximum of 20 words in a procedure step and 25
  words in a description.
- Write one instruction in each sentence. Start an instruction with a verb, for
  example "Run the tests."
- Use the active voice. Use the passive voice only when the actor is unknown or
  not important.
- Use simple verb tenses: present, past, and future. Do not use complex verb
  forms such as "would have been changed".
- Do not remove articles ("a", "an", "the"), verbs, or subjects to make a
  sentence shorter.

Words:

- Use common words. Use one word for one meaning, and use the same term for the
  same thing every time.
- Do not use idioms, slang, metaphors, or jokes. Use a single verb instead of a
  phrasal verb, for example "start" instead of "kick off".
- Do not use contractions. Write "do not", not "don't".
- Use the "-ing" form of a verb only in a noun or a technical name, for example
  "error handling".
- Do not put more than three nouns together. Write "the timeout for request
  retries", not "request retry timeout value".
- Be specific. Give numbers, units, names, versions, and links. Do not use vague
  words such as "some", "various", or "soon".
- Technical terms are permitted. Keep code, commands, file paths, error
  messages, and product names exactly as they are, in backticks.

Paragraphs and lists:

- Write one topic in each paragraph. Start the paragraph with a topic sentence.
  Use a maximum of six sentences in a paragraph.
- Use a numbered list for steps in a sequence. Use a bulleted list for other
  groups of items.
- Start a warning with a clear command or condition, for example "Do not run
  this command on a production host."

Example:

- Do not write: "We should probably look into refactoring the retry logic since
  it's been kind of flaky lately."
- Write: "The retry logic causes random test failures. Refactor the retry
  logic."

## Google Docs format

Use native Google Docs formatting, not Markdown. The document must not contain
Markdown markers such as `#`, `**`, or `|`. Apply the named styles (Title,
Heading 1, Heading 2, Heading 3, and Normal text) so that the document outline
works. Then apply the text styles below.

Structure, in this order:

1. The title, in the Title style.
2. A metadata line: "Owner: (person chip)  |  Created: (date chip)  |
   Updated: (date chip)".
3. "Executive Summary" or "Background" (Heading 1). Give the context, the goal,
   and the main result in four short paragraphs or fewer. If the scope has
   several parts, add a summary table.
4. For a document that needs sign-off: a Heading 2 that starts with "Review
   Status - Ask:", then the ask in normal text. Below it, add a reviewer table
   with the columns Reviewer, Team, Date, Status, and Comments. Use person chips
   for reviewers, date chips for dates, and the "Review status" dropdown (Not
   started, In progress, Under review, Approved) for the status.
5. The body sections (Heading 1), with subsections (Heading 2 and Heading 3).
   Examples: current state, evaluation or proposal, blockers, effort estimate,
   and rollout and rollback plan.
6. "Links" (Heading 1): a table with the columns Where and What.
7. Appendices (Heading 1), for example "Appendix A. Title". Put the detailed
   evidence in the appendices, and refer to them from the body.

Text styles:

| Element | Style |
|---|---|
| All text | Source Sans Pro, except code |
| Title | 25 pt, bold, blue `#0b57d0`, centered |
| Metadata line | 11 pt, gray `#718096`, centered |
| Heading 1 | 18 pt, bold, dark blue `#366091`, title case |
| Heading 2 | 15 pt, bold, blue `#4f81bd`, title case |
| Heading 3 | 13 pt, bold, blue `#4f81bd` |
| Normal text and lists | 11 pt, dark gray `#262626`, line spacing 1.05, 5 pt after |
| Table text | 11 pt, line spacing 1.0, 2 pt after |
| Code, commands, and identifiers | Source Code Pro, 10 pt |

Tables:

- Use tables for comparisons, inventories, plans, estimates, and review status.
- Before a table, write one or two sentences that tell what the table shows.
  Below the table, give the units and assumptions in a short note.
- Make the header row bold, with a light blue fill (`#d9eaf7`). Use 1 pt black
  borders, and align the cell content to the top.
- Align text columns to the left. Align number columns to the right.
- Make the row labels in the first column bold when each row is a category, a
  stage, or a requirement. Make group rows and total rows bold.
- Use a light red fill (`#f4cccc`) only for a cell that shows a blocker.
- Show the evidence for each claim, for example in a "How we know" column or
  with a source link in the cell.
- If a table shows only the top rows, add "Full list: (link)" below it.

Text, lists, and links:

- Start a paragraph or a bullet with a bold label, for example "Goal." or
  "Risk:".
- Use bullets for groups of items. Use numbered lists for steps and phases.
- Make a key term bold when you define it. Make key results and numbers bold.
- Use descriptive link text, not a raw URL. Link to code at a specific commit.
- Use "→" to show an order of stages, for example "test → staging →
  production".
- If a tool cannot insert a chip or a dropdown, write plain text in its place.
  Then tell me which items to change.

Page setup: use 0.5 in margins. For a table with many columns, use landscape
orientation or pageless mode.

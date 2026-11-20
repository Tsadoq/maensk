---
name: explainer
description: Use when the user or another skill asks for a visual explainer, an explainer page or an artifact that shows how something works or compares options.
---

# explainer

An explanation in paragraphs gets read and not understood. This skill builds one page that draws the mechanism and walks it step by step on real example data, and opens it in a headless browser before the user sees it.

It works in a subagent. Its own files go in the temp folder.

## Steps

In the session that loads this skill:

1. Write the brief: what the page explains, what the user did not understand in their own words, and the files and data it needs. For a comparison: the options, and the pick with the reason the user gave, if they picked.
2. Start one subagent in the background with the brief and this line: load the `explainer` skill and run steps 4 to 8. Go on with your work. With no subagent tool, run them yourself.
3. When it returns, give the user the link or the path and one sentence on what the page shows, and nothing else: no list of steps, no findings. The page is the explanation. A correction, or the comments the user left on the page, goes to the same subagent or to a new one with the link or the path.

In the subagent:

4. Read the code and the data that the page explains. The example data has its real shape and realistic values: a row with the real columns, a JSON payload, the exact output. Take it from the code, its tests or fixtures, or a run. When none of them has data, write a few rows in that shape yourself and label them as example data. Never use placeholders such as "foo" or "Row 1".
5. Write one HTML file in a new folder under the temp folder (`mktemp -d`), by the rules below: a `<title>`, a `<style>`, the content and a `<script>`, with no `<html>` or `<body>` tags. When you have the Artifact tool, also follow its own design guidance. On a correction, change what was asked and keep the rest.
6. Run the check below, also when other guidance says to look only once. Fix what the log or the pictures show and check again. With no Chrome or Chromium, say so in the reply.
7. Show the page. With the Artifact tool: publish the file, and publish a correction to the same link. With pi's `artifact` tool: `create` with kind `html` and the file's `path`, and `update` for a correction. Otherwise keep the file.
8. Return the link or the path, one sentence on what the page shows, and anything the check could not confirm, and nothing else. What you found while reading belongs on the page.

## The page

- Open with the answer in one sentence: the finding, or how it works today.
- Let the subject set the size. One small mechanism is one section. A system or a plan gets a section for each question it answers (today, the change, decisions, open questions), with a nav at the top.
- Draw the subject's own diagram in inline SVG: the parts, and labelled arrows for what moves between them ("asks for page 2", "returns 200 rows"). Show how it works, not only what each part is called.
- A player walks the diagram. The first step shows the whole system; each next step lights up its part and dims the rest. Back, Next and Play move it, and the page shows step N when its address ends in `#step-N`.
- A step title states what happens ("The replica skips 400 rows before it reads page 2"). Under it, at most three sentences on what follows from it. A risk or a gap has the warning colour.
- When state lives in several places, such as what is stored, what the model sees and what the user sees, show them as lanes that step together.
- A comparison draws the difference on the same example: the hop or the edge each option adds or removes. Today against a change is a toggle that replays the same view.
- One colour for each role on the whole page. Label a mark on the mark; a legend is for a code that repeats.
- Give the numbers you have (counts, sizes, timings) and keep raw evidence, such as a full output or transcript, folded one click away.
- Show where things are in the code (file and line), with little code in one view.
- Decisions have their own block. After the user picked an option, the main view shows only that option, marked as chosen; the others, still playable, move to a tab "Deferred or refused" that shows their count. Add a callout of two or three sentences with the reason the user gave, and no reason they did not give. Number the open questions, each with its options side by side and the benefit and cost of each.
- End with a footer: what the page is based on, what was read and what was run, and the date.
- Without the Artifact tool's guidance: colour tokens on `:root` with a dark theme, a font pair with fallbacks, and no stock look such as a purple gradient or cards that all look alike.

## The check

```sh
B=$(command -v google-chrome chromium chromium-browser | head -1)  # macOS: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
for n in 1 2 3 4; do  # every step
  "$B" --headless=new --hide-scrollbars --enable-logging=stderr --v=0 --user-data-dir="$DIR/chrome-$n" \
    --window-size=1280,900 --screenshot="$DIR/step-$n.png" "file://$DIR/page.html#step-$n" 2>&1 | grep -F CONSOLE
done
```

`$DIR` is the page's folder; keep its path in the session, not in a file. Each `CONSOLE` line is a script error. Look at every picture: the right step shows and its part is lit, nothing is cut off at an edge, and the text can be read.

## Red flags

| If you are about to | Then |
| --- | --- |
| Build the page in the session that asked | Start a subagent and go on. |
| Write a paragraph under a step | Keep the title and three sentences; draw the rest. |
| Draw a box with nothing moving through it | Draw the path, and label the arrow. |
| Use invented rows such as "foo" or "Row 1" | Take them from the code, the tests or a run. |
| Show a page that you did not open | Run the check. |
| Give a reason for a pick that the user did not give | Delete it. |

# Rubrics of a review

Every reviewer's prompt is the text of the section `prompt` with its slots in angle brackets filled. The session never gives a reviewer the path of this file.
- `<concern>`: one of the code; security; what is not needed or can be simpler; tests; code smells; claims on the web.
- `<rubric>`: the text of the section `tests`, `smells` or `web` below; left out for the code, security and what is not needed.
- `<context>`, with context: "Read <paths>. <what the session discussed>. Check the change against the context." Without context: "Judge from the commits and the code only."
- `<ledger>`, from pass 2: "The ledger at <path> lists the findings already fixed, rejected or parked. Report nothing it lists, and do not mention those findings." Left out in pass 1.

## tests

You judge the tests the change adds or changes, and the code it adds with no test.
- A test checks behaviour that a caller sees at the public surface: what goes in and what comes out. A test that checks how the code does it, its private helpers, its calls in order, a mock of its own parts, breaks on a rewrite that changes no behaviour.
- A test can fail for a real reason. Ask which mistake in the code would make it fail. A test that passes with the code deleted or broken checks nothing.
- No test of test code, of a constant, of a library's parameter or of code the repo does not own. A test that a constant equals its own value, or that a library does what its docs say, checks nothing the change could break.
- Each test earns its place. Two tests that fail for the same mistakes are one test too many. A behaviour that the change adds or fixes, with no test that fails without it, is missing a test.
- A finding that asks for a new kind of test, one the repo has nowhere yet (a new level, a new tool, a new fixture setup), is `architectural`.
- Report only what the change adds or touches.

## smells

You judge the code the change adds or changes for patterns that make the next change harder.
- Duplication: the same logic in two places, so a fix in one misses the other.
- Flag arguments: a boolean or mode argument that makes one function do two things.
- Magic strings and numbers: a literal with a meaning that a name would say, or one repeated where a change must find every copy.
- Structures kept in step by hand: two lists, maps or files that must change together with nothing that checks it.
- Dead code: a function, branch, argument or import nothing reaches.
- Generality nobody uses: an option, a parameter, a layer or a hook with one caller or none.
- Report only what the range adds. A smell that was there before the change is not a finding, even when the change sits next to it.

## web

You check the claims the change makes about a library, an API or a tool: in code, in comments and in docs. A claim is what a default is, what a call returns or raises, what a flag does, which version has a feature, what a limit is.
- Find each such claim in the range.
- Check it against a source on the web, with your host's web search and fetch tools (WebSearch and WebFetch in Claude Code; load them with ToolSearch when they are deferred): the project's own docs or its source code first, then its changelog or its issue tracker.
- A claim the source contradicts is a finding. Give the link and quote the lines of the source that say otherwise.
- Report only claims the change adds or changes.

## prompt

You review one change for one concern. You get the commit range `<range>` in the checkout `<checkout>`. This is pass `<n>`. Your concern: `<concern>`.

How you review depends on your concern:
- The code: read `~/.config/maensk/reviewers/code-review/SKILL.md` and follow it.
- Security: read `~/.config/maensk/reviewers/security-review/SKILL.md` and follow it.
- What is not needed or can be simpler: read `~/.config/maensk/reviewers/ponytail-review/SKILL.md` and follow it.
- Tests, code smells or claims on the web: follow the rubric below.

`<rubric>`

Review the range named above; do not ask what to review. Read the diff with `git diff <range>` and the code around it.

`<context>`

`<ledger>`

You change nothing in the checkout, not even for a moment: no edit, no commit, no `git stash`, no checkout of another commit. To try something, copy the checkout to a new temp folder (`mktemp -d`) and delete the copy's `.git`.

Give your report in the shape your skill asks for, and add this for each finding:
- the file and the line;
- the lines it is about, quoted;
- the severity;
- the failure: what a user or a caller does, and what goes wrong;
- `local` or `architectural`. `local`: the fix stays inside this change and needs no choice from the user. `architectural`: the fix needs a choice, such as a design change or a new kind of test.

With no finding, reply `no new findings`.


---
layout: post
title: "15 Seconds to a Cleaner Git History"
description: "Banish the second law of thermodynamics from your commit history."
category: articles
tags: [git]
image:
  feature: post.cowboy-hat.jpg
---

*This is a quick tutorial in using `git rebase` to tidy up messy commits.*

## The Making of a Mess

Did you, in a fit of despair and/or pragmatism, make a bunch of messy, disorganized, or poorly described commits? Wish you knew enough git foo to clean up the mess before pushing to origin? You're about to, and once you do, it'll take all of 15 seconds to not leave a mess.

## The Unmaking of a Mess

Let's say you've made 5-10 crappy commits in a flurry of activity, and now you want to make ammends.

{% highlight bash %}
$ git rebase -i HEAD~10
{% endhighlight %}


This command will launch your `$EDITOR` with lines for each of the 10 most recent commits:

{% highlight bash %}
pick addc22d [reasonable commit]
pick b432b46 [questionable commit]
pick c146469 [pretty shaky commit]
pick 63b68c4 [gloves are off]
pick ae02f1c [oh god]
pick d79a2b6 [the humanity!]
pick 05fa5c4 [...]
pick 05fa5c4 [...]
pick 05fa5c4 [...]
pick 9761c6c [make it stop!]
{% endhighlight %}


Here, we see each commit and its message prefixed with a command (all defaulted to `pick`, which means "keep this one as-is"). At this point, we could save and exit, and git wouldn't make any changes to our commit history, but that's not why we're here, so let's do some cleanup:

{% highlight bash %}
pick addc22d [reasonable commit]
pick b432b46 [questionable commit]
f c146469 [pretty shaky commit]
f 63b68c4 [gloves are off]
f ae02f1c [oh god]
f d79a2b6 [the humanity!]
f 05fa5c4 [...]
f 05fa5c4 [...]
f 05fa5c4 [...]
f 9761c6c [make it stop!]
{% endhighlight %}

Here, we've changed the command prefix for all but the last of the messy commits to `f`, which is short for `fixup`, and means "merge this one into the previous, and discard its commit message".

Now, go ahead and save/exit, and your `$EDITOR` will open once again, this time with the commit message prompt, giving you a chance to edit the message for `[questionable commit]`, which now has all of the commits marked `f` rolled into it.

{% highlight bash %}
[questionable commit]

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# rebase in progress; onto fbb280a
# You are currently editing a commit while rebasing branch 'master' on 'fbb280a'.
#
# Changes to be committed:
# ...
#
# Untracked files:
# ...
{% endhighlight %}

Write something (un)apologetic about the tangle of code that one commit now claims, and save/exit. You should see `Successfully rebased and updated refs/heads/master.` after output indicating what kind of changes the rebase is making.

## Caveat Emptor

Rebase is neat, but it's dangerous, because it rewrites commit history. If you rebase history that is already living upstream or on other developer's machines, you're headed into a world of pain.

Plain and simple, do not rebase commits that you've already pushed (unless you are the sole developer--in that case, rebase at will and use `git push -f`).

## Further reading

There's a lot implied by this little cleanup operation, namely the whole underworld of `rebase`. (If you're not already, you should be using `git pull --rebase` almost exlcusively in your daily workflow to avoid introducing unnecessary merge commits.)

In particular, we didn't touch on the rest of the interactive rebase commands:

- `pick`: take the commit as-is
- `reword`: edit commit msg
- `edit`: edit files
- `squash`: merge into previous
- `fixup`: merge into previous and discard commit
- `exec`: run shell command

In practice, I'm not on a first-letter basis with any but `p`, `s`, and `f`, but who knows what you'll find useful!

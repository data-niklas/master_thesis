#import "/utils.typ": *
= Introduction <introduction>
// Code completion is
Code completion provides code suggestions to developers extending their incomplete code.
The suggestions used multimodal data sources to combine a variety of information.

It is one of the most used productivity tools in #acrpl("IDE"). Every major #acr("IDE") from VSCode, Jetbrains #acrpl("IDE"), Eclipse, Neovim and Emacs with plugins support code completion.
// Shows methods, properties of objects including documentation
It reduces the mental burden of remembering method names, properties, their types and associated information, such as documentation and if the item is deprecated.
In addition, it saves time by reducing written boilerplate code by suggesting code snippets.
Using the code completion saves time spent searching for corresponding documentation outside the #acrpl("IDE").

As Amann et al.@amannStudyVisualStudio2016 found, code completion is the most frequently used tool inside #acrpl("IDE") with a frequency of 19.7%.
Moreover, developers spend 22.4% of their time inside #acrpl("IDE") navigating code, in contrast to 28.5% editing and executing the code. They hypothesize that a significant amount of time navigating code is spent due to a lack of understanding of the code.
Moreover, 39.8% of the total time is spent outside the #acr("IDE"), which likely includes time spent searching for documentation.
// Even displays information like deprecation information
// Saves time spent looking up documentation
// Facts
// - Time spent outside
// - Most used tool
// - Navigation
// Importance of code completion

Good code completion is a crucial tool for developers, reducing time spent in total and reducing the time spent outside the #acr("IDE"), further increasing the focus of the developer.

/* ~ General flow ~
  1. Code gen horribly bad, outdated or slow or inaccurate
  2. Fast, accurate, dynamic to code (choose to generate for old code, it works both ways!!!!)
  3. (2) is goal (3) is the fact check where I sell my project
*/

#{
  include "1_motivation.typ"
  include "2_goals.typ"
  include "3_contributions.typ"
}

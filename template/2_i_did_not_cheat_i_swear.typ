#let i-did-not-cheat-i-swear(name, print-mode, submission-date) = context {
  set page(header: none, footer: none)
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  v(40pt)
  [I hereby certify that I have written the work myself and that I have not used any sources
    or aids other than those specified, and that I have marked what has been taken over from
    other people’s works, either verbatim or in terms of content, as foreign. I also certify
    that the electronic version of my thesis transmitted completely corresponds in content
    and wording to the printed version. I agree that this electronic version is being checked
    for plagiarism at the university using plagiarism software.]
  v(50pt)
  [Heidelberg, the #submission-date.display("[year]-[month]-[day]")]
  v(15pt)
  line(length: 6cm, stroke: 0.02cm + black)
  name
  if calc.rem(counter(page).get().last(), 2) == 1 and print-mode {
    pagebreak()
    align(center + horizon, [_Page intentionally left empty_])
  }
  let to = if print-mode {
    "odd"
  } else {
    none
  }
  pagebreak(to: to, weak: true)
}

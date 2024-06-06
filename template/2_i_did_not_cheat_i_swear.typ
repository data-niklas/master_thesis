#let i-did-not-cheat-i-swear(name) = {
  set page(header: none, footer: none)
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  v(40pt)
  [I hereby certify that I have written the work myself and that I have not used any sources
or aids other than those specified and that I have marked what has been taken over from
other people’s works, either verbatim or in terms of content, as foreign. I also certify
that the electronic version of my thesis transmitted completely corresponds in content
and wording to the printed version. I agree that this electronic version is being checked
for plagiarism at the university using plagiarism software.]
  v(50pt)
  [Heidelberg, den #datetime.today().display("[year]-[month]-[day]")]
  v(15pt)
  line(length: 6cm, stroke: 0.02cm + black)
  name
  pagebreak(to: "odd", weak: true)
}

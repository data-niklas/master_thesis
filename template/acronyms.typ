#import "@preview/acrotastic:0.1.0": *

// Monkey-patched from https://github.com/Julian702/typst-packages/blob/46378f36075f2da63db26c8d62c3612f11834255/packages/preview/acrotastic/0.1.0/acrotastic.typ#L111C1-L130C2
// necessary change: add outlined parameter
// additionally: changed defaults
#let print-index(title: "Acronyms", outlined: true, sorted: "up", delimiter: ":", acr-col-size: 20%, level: 1) = {
  assert(sorted in ("keep","up","down"), message:"Sorted must be a string either \"keep\", \"up\" or \"down\"")
  if title != "" {heading(level: level, outlined: outlined)[#title]}
  acros.display(acronyms=>{
    let acr-list = acronyms.keys()
    if sorted == "up" {
      acr-list = acr-list.sorted()
    } else if sorted == "down" {
      acr-list = acr-list.sorted().rev()
    }
    for acr in acr-list{
      table(
        columns: (acr-col-size,100%-acr-col-size),
        stroke:none,
        inset: 0pt,
        [*#acr#label(acr)#delimiter*], [#acrl(acr, link: false)]
      )
    }
  })
}

// uppercase versions of acronym printing

#let Display(acr, text, link: true) = {
  let uppercased_text = upper(text.first()) + text.slice(1, none)
  if link {display-link(acr, uppercased_text)} else {uppercased_text}
}

// Display acronym in long form.
#let Acrl(acr, plural: false, link: true) = {
  acros.display(acronyms => {
    if is-valid(acr) {
      let defs = acronyms.at(acr)
      if type(defs) == "string" {
        if plural {
          Display(acr, defs + "s", link: link)
        } else {
          Display(acr, defs, link: link)
        }
      } else if type(defs) == "array" {
        if defs.len() == 0 {
          panic("No definitions found for acronym " + acr + ". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
        }
        if plural {
          if defs.len() == 1 {
            Display(acr, defs.at(0) + "s", link: link)
          } else if defs.len() == 2 {
            Display(acr, defs.at(1), link: link)
          } else {
            panic("Definitions should be arrays of one or two strings. Definition of " + acr + " is: " + type(defs))
          }
        } else {  
          Display(acr, defs.at(0), link: link)
        }
      } else {
        panic("Definitions should be arrays of one or two strings. Definition of " + acr + " is: " + type(defs))
      }
    }
  })
}
// Display acronym in long plural form.
#let Acrlpl(acr, link: true) = {Acrl(acr, plural: true, link: link)}

#let Acrf(acr, plural: false, link: true) = {
  if plural {
    display(acr, [#Acrlpl(acr) (#acr\s)], link: link)
  } else {
    display(acr, [#Acrl(acr) (#acr)], link: link)
  }
  state(prefix + acr, false).update(true)
}
// Display acronym in plural form for the first time.
#let Acrfpl(acr, link: true) = {Acrf(acr, plural: true, link: link)}

// Display acronym. Expands it if used for the first time.
#let Acr(acr, plural: false, link: true) = {
  state(prefix + acr, false).display(seen => {
    if seen {
      if plural {acrspl(acr, link: link)} else {acrs(acr, link: link)}
    } else {
      if plural {Acrfpl(acr, link: link)} else {Acrf(acr, link: link)}
    }
  })
}
// Display acronym in the plural form. Expands it if used for the first time. 
#let Acrpl(acronym, link: true) = {Acr(acronym, plural: true, link: link)}

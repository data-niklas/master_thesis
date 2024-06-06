#let show-abstract(abstract, language) = {
    align(start+horizon, {

    align(center, text(size: 14pt, smallcaps("Abstract")))
    align(center, text(style: "italic")[\- #language -])
    v(10pt)
    abstract
    })
    pagebreak(weak: true)
}

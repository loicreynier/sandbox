#let conf(title: none, authors: (), abstract: [], doc) = {
  set document(title: title, author: authors.first().name)

  set page(paper: "a4", numbering: "1/1")

  set text(font: "New Computer Modern", size: 11pt)

  set align(center)
  text(17pt)[*#title*]

  set math.equation(numbering: "(1)", supplement: [Eq.])

  show heading: hname => [
    #set align(center)
    #set text(12pt, weight: "bold")
    #block(smallcaps(hname.body))
  ]

  let count = authors.len()
  let ncols = calc.min(count, 3)
  grid(columns: (1fr,) * ncols, row-gutter: 24pt, ..authors.map(author => [
    #author.name \
    #author.affiliation \
    #link("mailto:" + author.email)
  ]))

  par(justify: true)[
    *#smallcaps("Abstract")* \
    #abstract
  ]

  set par(justify: true)
  set align(left)
  // columns(2, doc)
  doc
}

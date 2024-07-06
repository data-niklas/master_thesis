#import "@preview/sourcerer:0.2.1": code

#let create_bib_row(key, value) = {
  return "    " + key + " = {" + value + "},\n"
}

#let generate_bib_entry(title, author, thesis-repo, publish_date) = {
  let id = lower(author.replace(" ", "_")) + "_" + str(publish_date.year())
  let text = "@thesis{" + id + ",\n" + create_bib_row(
    "title",
    title,
  ) + create_bib_row("author", author) + create_bib_row(
    "year",
    str(publish_date.year()),
  ) + create_bib_row("month", str(publish_date.month())) + create_bib_row(
    "school",
    "Heidelberg University",
  ) + create_bib_row(
    "url",
    thesis-repo,
  ) + "}"
  code(raw(text, lang: "bib", block: true), lang: "BibTex")
}


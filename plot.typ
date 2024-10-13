#import "/utils.typ": cetz, strfmt
#import "/eval.typ": total-stats, average-stats, map-approach-configuration-name

#let bwr-colors = csv("/assets/colors/bwr.csv")

#let palette-color(palette, value) = {
  let index = calc.floor(value * (palette.len() - 1))
  color.rgb(
    ..palette.at(index).map(i => {
      calc.floor(float(i) * 255)
    }),
  )
}

#let fmt-float(number, prefix: false) = {
  let rounded-number = calc.round(number, digits: 2)
  if rounded-number == 0 and prefix {
    sym.plus.minus + str(rounded-number)
  } else if rounded-number > 0 and prefix {
    sym.plus + str(rounded-number)
  } else if rounded-number >= 0 {
    str(rounded-number)
  } else {
    sym.minus + str(rounded-number * -1)
  }
}
#let task-sorted-key(task) = (
  task.at(1).at("full_p"),
  task.at(1).at("partial_p"),
  task.at(1).at("none_p"),
  task.at(1).at("error_p"),
)

#let stats-table(stats, show-total: true, diff: false, use-color: true) = {
  let align = (column, row) => {
    if row == 0 {
      center + horizon
    } else if column == 0 {
      left + horizon
    } else {
      right + horizon

    }
  }
  let header = (
    "Name",
    "Total",
    [Fully\ solved],
    [Partially\ solved],
    [Not\ solved],
    text(hyphenate: false)[Error],
  )
  if not show-total {
    let _ = header.remove(1)
  }
  if diff {
    header += ("Unchanged",)
  }
  let columns = header.len()
  table(
    columns: columns,
    align: align,
    table.header(..header),
    ..stats.map(name-stat => {
      let name = name-stat.at(0)
      let stat = name-stat.at(1)
      let get-stat(key) = {
        let value = stat.at(key)
        if diff and key != "unchanged_p" {
          fmt-float(value, prefix: true)
        } else {
          fmt-float(value, prefix: false)
        }
      }
      let get-p(
        key,
      ) = {
        let key_p = key + "_p"
        let value = if key_p in stat {
          if diff or not show-total {
            get-stat(key_p) + "%"
          } else {
            get-stat(key_p) + "% (" + get-stat(key) + ")"
          }
        } else {
          get-stat(key)
        }
        if diff and key != "unchanged" and key_p in stat and use-color and stat.at(key) != 0 {
          let perc = calc.min(calc.abs(stat.at(key_p)) / 26, 1) / 2 + 0.5
          // perc = perc * 100%
          let use-blue = stat.at(key) > 0
          if key == "error" or key == "none" {
            use-blue = not use-blue
          }
          let weak-bwr-colors = bwr-colors.slice(60, 180)
          let color = if use-blue {
            palette-color(
              weak-bwr-colors.rev(),
              perc,
            )
            // color.hsl(
            //   107deg,
            //   perc,
            //   50%,
            // )
          } else {
            palette-color(
              weak-bwr-colors,
              perc,
            )
            // color.hsl(
            //   9deg,
            //   perc,
            //   50%,
            // )
          }
          // set text(fill: color)
          // value
          table.cell(fill: color, value)
        } else if key_p in stat and use-color and key != "unchanged" and stat.at(key) != 0 {
          let red-deg = 9deg
          let green-deg = 107deg
          let perc = 1 - stat.at(key_p) / 100
          let deg = red-deg + perc * (green-deg - red-deg)
          // if key == "error" or key == "none" {
          //   perc = 1 - perc
          // }
          let use-blue = true
          // let color = palette-color(bwr-colors, perc)
          if key == "error" or key == "none" {
            use-blue = not use-blue
          }
          let half-index = calc.floor(bwr-colors.len() / 2)
          let blue-colors = bwr-colors.slice(0, half-index)
          let red-colors = bwr-colors.slice(half-index, 240).rev()
          let color = if use-blue {
            palette-color(
              blue-colors,
              perc,
            )
            // color.hsl(
            //   107deg,
            //   perc,
            //   50%,
            // )
          } else {
            palette-color(
              red-colors,
              perc,
            )
            // color.hsl(
            //   9deg,
            //   perc,
            //   50%,
            // )
          }
          // let color = color.hsl(
          //   deg,
          //   100%,
          //   46%,
          // )
          // set text(fill: color)
          //value
          table.cell(fill: color, value)
        } else {
          value
        }
      }
      let full = get-p("full")
      let partial = get-p("partial")
      let nil = get-p("none")
      let error = get-p("error")
      let result = (name, full, partial, nil, error)
      if show-total {
        let total = stat.at("total")
        let _ = result.insert(1, str(total))
      }
      if diff and "unchanged" in stat {
        let unchanged = get-p("unchanged")
        result = result + (unchanged,)
      }
      result
    }).flatten(),
  )
}
#let task-stats-table(task-stats, show-total: true, diff: false) = {
  let final-row = if not show-total {
    ("Average", average-stats(task-stats.values()))
  } else {
    ("Total", total-stats(task-stats.values()))
  }
  stats-table(
    show-total: show-total,
    diff: diff,
    task-stats.pairs().sorted(key: task-sorted-key).rev() + (final-row,),
  )
}

#let draw-legend(
  items,
  name: none,
  side: left,
  anchor: "center",
  text-inset: 0.12pt,
  text-size: 8pt,
  box-padding: 0.1pt,
) = {
  let color-length = text-size * 1.2
  let color-width = color-length * 0.3
  let text-anchor = if side == left {
    "west"
  } else {
    "east"
  }
  cetz.draw.group(
    {
      cetz.draw.group(
        {
          for i in range(items.len()) {
            let item = items.at(i)
            let label-text = item.at(0)
            let color = item.at(1)
            let content-x = if side == left {
              color-width + text-inset
            } else {
              -text-inset
            }
            cetz.draw.rect(
              (0, color-length * -i),
              (color-width, color-length * (-i - 1)),
              fill: color,
              stroke: color,
            )
            cetz.draw.content(
              (content-x, color-length * -(i + 0.5)),
              {
                set text(text-size)
                label-text
              },
              anchor: text-anchor,
            )
          }
        },
        name: name + "_inner",
      )
      cetz.draw.on-layer(
        -1,
        cetz.draw.rect(
          (rel: (-box-padding, box-padding), to: name + "_inner.north-west"),
          (rel: (box-padding, -box-padding), to: name + "_inner.south-east"),
          radius: 4pt,
          stroke: 0.3pt,
          fill: color.rgb("#f0f0f0"),
        ),
      )
    },
    name: name,
    anchor: anchor,
  )
}

#let stats-column-charts(
  results,
  diff: false,
  two-rows: false,
  width: none,
  height: none,
  x-label: "Tasks",
  colors: (
    "#52D726",
    "#007ED6",
    "#d229db",
    "#db2929",
    "#555555",
  ).map(color.rgb),
) = {
  cetz.canvas(
    {
      import cetz.chart
      import cetz.draw: *
      let value-keys = (1, 2, 3, 4)
      if diff {
        value-keys += (5,)
      }
      let stat-to-list(stat) = {
        let full = stat.at("full")
        let partial = stat.at("partial")
        let nil = stat.at("none")
        let error = stat.at("error")
        let data = (full, partial, nil, error)
        let total = data.map(calc.abs).sum()
        if diff {
          let unchanged = stat.at("unchanged")
          data += (unchanged,)
          total += calc.abs(unchanged)
        }
        let to-perc(value) = calc.round(value / total * 100, digits: 1)
        data = data.map(to-perc)
        data
      }
      let stats = results.map(name-stat => (
        name-stat.at(0),
        ..stat-to-list(name-stat.at(1)),
      ))
      set-style(columnchart: (x-inset: 0.45, bar-width: 0.6))

      let names = (
        "Full",
        "Partial",
        "Not solved",
        "Error",
      )
      if diff {
        names += ("Unchanged",)
      }
      group(
        {
          let chart-width = if width != none {
            width
          } else {
            11 / 5 * results.len()
          }
          let chart-height = if height != none {
            height
          } else {
            3.8
          }
          chart.columnchart(
            stats,
            mode: "stacked",
            label-key: 0,
            value-key: value-keys,
            size: (chart-width, chart-height),
            bar-style: cetz.palette.new(colors: colors),
            y-label: [Task Completion $(%)$],
            x-label: x-label,
            labels: names,
          )
        },
        name: "stats",
      )
      // set-origin((
      //   rel: (1.6, 8pt * 1.2 * names.len() / 2 + 10pt),
      //   to: "stats.east",
      // ))
      // draw-legend(
      //   names.zip(colors).rev(),
      //   side: right,
      //   box-padding: 2.5pt,
      //   text-inset: 3pt,
      //   text-size: 8pt,
      // )
    },
    length: 30pt,
  )

}

#let error-card(error-groups, errors-field: "errors-generation") = {
  let align = (column, row) => {
    if row == 0 {
      center + horizon
    } else if column == 0 {
      left + horizon
    } else {
      right + horizon

    }
  }
  let header(name) = table.cell(colspan: 2, align: center, [*#name*])
  let total = error-groups.at("total")
  let format-value(value) = {
    fmt-float(value / total * 100) + "%"
  }
  let items = ()
  // 1. total errors
  // 2. errors-by-field
  // 3. model, configurations (model, approach)
  // 4. by scenario
  items += ([Total], [#error-groups.at("total")])
  items += (table.hline(), header("Models"))
  for model in error-groups.at("by-model") {
    items += (model.at(0), format-value(model.at(1)))
  }
  items += (table.hline(), header("Model Configurations"))
  for value in error-groups.at("by-beams") {
    items += ([#value.at(0) beams], format-value(value.at(1)))
  }
  items += (table.hline(),)
  for value in error-groups.at("by-sampling") {
    let text = if value.at(0) {
      "Sampling"
    } else {
      "No sampling"
    }
    items += ([#text], format-value(value.at(1)))
  }
  items += (table.hline(), header("Approach Configurations"))
  for value in error-groups.at("by-approach") {
    items += (
      map-approach-configuration-name(value.at(0)),
      format-value(value.at(1)),
    )
  }
  items += (table.hline(), header("Tasks"))
  for value in error-groups.at("by-task") {
    items += ([#value.at(0)], format-value(value.at(1)))
  }
  items += (table.hline(), header("Errors"))
  for value in error-groups.at(errors-field) {
    items += ([#value.at(0)], format-value(value.at(1)))
  }
  table(
    columns: 2,
    align: align,
    table.header([Group Name], [Group Occurence]),
    ..items,
  )
}

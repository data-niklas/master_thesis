#import "/utils.typ": cetz, strfmt
#import "/eval.typ": total-stats, average-stats

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

#let stats-table(stats, show-total: true, diff: false) = {
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
        if key_p in stat {
          if diff {
            get-stat(key_p) + "%"
          } else {
            get-stat(key_p) + "% (" + get-stat(key) + ")"
          }
        } else {
          get-stat(key)
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
      if diff {
        let unchanged = get-p("unchanged")
        result = result + (unchanged,)
      }
      result
    }).flatten(),
  )
}
#let task-stats-table(task-stats, show-total: true, diff: false) = {
  let final-row = if show-total {
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

#let stats-pie-charts(results, diff: false) = {
  cetz.canvas(
    {
      import cetz.chart
      import cetz.draw: *

      let colors = gradient.linear(red, blue, green, yellow)
      colors = gradient.linear(
        ..(
          "#dc8a78",
          "#8839ef",
          "#d20f39",
          "#d20f39",
          "#40a02b",
          "#04a5e5",
          "#7287fd",
        ).map(color.rgb),
      )
      for result in results {
        let name = result.at(0)
        let stat = result.at(1)
        let full = stat.at("full")
        let partial = stat.at("partial")
        let nil = stat.at("none")
        let error = stat.at("error")
        let data = (
          ("Full", full),
          ("Partial", partial),
          ("None", nil),
          ("Error", error),
        )

        chart.piechart(
          data,
          outset: 0.3,
          value-key: 1,
          label-key: 0,
          slice-style: colors,
        )
        set-origin((3, 0))
      }
    },
    length: 30pt,
  )

}

import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

export interface Options {
  text?: string
  href?: string
}

export default ((userOpts?: Partial<Options>) => {
  const opts: Options = {
    text: "WIS Manual",
    href: "https://wis-wiki-manual.web.app/",
    ...userOpts,
  }

  const PageTitle: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
    return (
      <h2 class={classNames(displayClass, "page-title")}>
        <a href={opts.href}>{opts.text}</a>
      </h2>
    )
  }

  PageTitle.css = ".page-title { font-size: 1.75rem; margin: 0; font-family: var(--titleFont); } .page-title a { border-bottom: none; color: var(--dark); text-decoration: none; } .page-title a:hover { border-bottom: none; }"

  return PageTitle
}) satisfies QuartzComponentConstructor

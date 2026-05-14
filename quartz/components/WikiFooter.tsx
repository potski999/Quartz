import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

const WikiFooter: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
  return (
    <footer class={classNames(displayClass, "wis-footer")}>
      <div class="container">
        <ul class="footer-links">
          <li><a href="/">Manual</a></li>
          <li><a href="https://wis-wiki.web.app/videos.html">Videos</a></li>
          <li><a href="https://forums.matrixgames.com/viewforum.php?f=12043">Forum</a></li>
        </ul>
        <div class="copyright">© 2026 WIS <span class="accent">Wiki</span>. Developed for the WIS community.</div>
      </div>
    </footer>
  )
}

WikiFooter.css = ".wis-footer { padding: 32px 0; border-top: 1px solid var(--border); text-align: left; opacity: 1; } .wis-footer .container { display: flex; justify-content: space-between; align-items: center; max-width: 1100px; margin: 0 auto; padding: 0 24px; } .wis-footer .footer-links { display: flex; gap: 24px; list-style: none; margin: 0; padding: 0; } .wis-footer .footer-links a { font-family: var(--font-mono); font-size: 11px; color: var(--muted); text-decoration: none; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: none; } .wis-footer .footer-links a:hover { color: var(--fg); border-bottom: none; } .wis-footer .copyright { font-family: var(--font-mono); font-size: 11px; color: var(--muted); } .wis-footer .copyright .accent { color: var(--accent); }"

export default (() => WikiFooter) satisfies QuartzComponentConstructor

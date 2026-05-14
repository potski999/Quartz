import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

const NavBar: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
  return (
    <nav class={classNames(displayClass, "wis-nav")}>
      <div class="container">
        <a href="https://wis-wiki.web.app/" class="logo">WIS <span>Wiki</span></a>
        <ul class="nav-links">
          <li><a href="https://wis-wiki.web.app/index.html#resources">Resources</a></li>
          <li><a href="https://wis-wiki.web.app/videos.html">Videos</a></li>
          <li><a href="https://wis-wiki.web.app/history.html">History</a></li>
          <li><a href="https://wis-wiki.web.app/scenarios.html">Scenarios</a></li>
          <li><a href="/" class="active">Manual</a></li>
        </ul>
      </div>
    </nav>
  )
}

NavBar.css = ".wis-nav { position: fixed; top: 0; left: 0; right: 0; z-index: 1000; background: oklch(99% 0.003 250 / 0.85); backdrop-filter: blur(12px); border-bottom: 1px solid var(--border); height: 56px; display: flex; align-items: center; } .wis-nav .container { display: flex; align-items: center; justify-content: space-between; width: 100%; max-width: 1100px; margin: 0 auto; padding: 0 24px; } .wis-nav .logo { font-family: var(--font-mono); font-size: 13px; font-weight: 600; letter-spacing: 0.5px; color: var(--fg); text-decoration: none; cursor: pointer; border-bottom: none; } .wis-nav .logo:hover { border-bottom: none; } .wis-nav .logo span { color: var(--accent); } .wis-nav .nav-links { display: flex; gap: 0.5rem; list-style: none; margin: 0; padding: 0; flex-wrap: wrap; justify-content: flex-end; } .wis-nav .nav-links a { font-family: var(--font-mono); font-size: 12px; color: var(--muted); text-decoration: none; text-transform: uppercase; letter-spacing: 0.5px; transition: color 0.15s ease; padding: 4px 8px; border-bottom: none; } .wis-nav .nav-links a:hover { color: var(--accent); border-bottom: none; } .wis-nav .nav-links a.active { color: var(--accent); } @media (max-width: 768px) { .wis-nav { height: auto; padding: 8px 0; } .wis-nav .container { flex-direction: column; gap: 8px; } .wis-nav .nav-links { gap: 0.25rem; } .wis-nav .nav-links a { font-size: 11px; padding: 2px 6px; } }"

export default (() => NavBar) satisfies QuartzComponentConstructor


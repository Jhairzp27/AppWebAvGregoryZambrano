<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<!DOCTYPE html>

<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#0C0908" />
    <title>PoliMusic · Canciones</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        /* ==================================================================
           PoliMusic · Song.aspx
           1. Tokens  2. Base  3. Layout  4. Sidebar  5. Topbar
           6. Hero    7. Stats 8. Lista   9. Reproductor
           10. Modales 11. Toasts 12. Responsive
           ================================================================== */

        /* ---------- 1. TOKENS ---------- */
        :root {
            --brand: #FF6B00;
            --brand-light: #FFA14A;
            --brand-dark: #C74900;
            --grad: linear-gradient(135deg, #FFA14A 0%, #FF6B00 52%, #D94500 100%);
            --grad-soft: linear-gradient(135deg, rgba(255, 107, 0, .16), rgba(217, 69, 0, .06));

            --bg: #0C0908;
            --bg-deep: #070505;
            --text: #F8F4EF;
            --muted: #9C9188;
            --muted-dim: #6E645D;

            --glass: linear-gradient(158deg, rgba(255, 255, 255, .07), rgba(255, 255, 255, .02));
            --glass-2: linear-gradient(158deg, rgba(255, 255, 255, .1), rgba(255, 255, 255, .03));
            --line: rgba(255, 255, 255, .08);
            --line-2: rgba(255, 255, 255, .15);

            --ok: #35D399;
            --danger: #FF6B6B;

            --r-xs: 10px;
            --r-sm: 14px;
            --r-md: 18px;
            --r-lg: 26px;
            --r-xl: 34px;

            --shadow: 0 30px 80px -40px rgba(0, 0, 0, .95), inset 0 1px 0 rgba(255, 255, 255, .08);
            --glow: 0 16px 40px -18px rgba(255, 107, 0, .75);

            --side: 258px;
            --player: 96px;
            --top: 66px;

            --ease: cubic-bezier(.22, 1, .36, 1);
            --spring: cubic-bezier(.34, 1.32, .64, 1);
        }

        /* ---------- 2. BASE ---------- */
        *, *::before, *::after { box-sizing: border-box; }

        html, body { min-height: 100%; }

        body {
            margin: 0;
            font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            font-size: 15px;
            line-height: 1.5;
            color: var(--text);
            background: var(--bg);
            -webkit-font-smoothing: antialiased;
            overflow-x: hidden;
        }

        h1, h2, h3, h4 {
            font-family: "Outfit", "Inter", sans-serif;
            margin: 0;
            font-weight: 600;
            letter-spacing: -.02em;
        }

        p { margin: 0; }
        a { color: inherit; text-decoration: none; }
        code { font-family: ui-monospace, "SFMono-Regular", Consolas, monospace; font-size: .92em; color: var(--brand-light); }

        button {
            font-family: inherit; font-size: inherit; color: inherit;
            background: none; border: 0; cursor: pointer;
        }

        svg { width: 20px; height: 20px; display: block; }
        img { max-width: 100%; }

        ::selection { background: rgba(255, 107, 0, .35); color: #fff; }
        :focus-visible { outline: 2px solid var(--brand-light); outline-offset: 2px; border-radius: 8px; }

        /* Manchas de color: le dan materia al glassmorphism */
        .aura { position: fixed; inset: 0; z-index: 0; overflow: hidden; pointer-events: none; }
        .aura i { position: absolute; display: block; border-radius: 50%; filter: blur(100px); }
        .aura .a1 { width: 640px; height: 640px; top: -260px; left: -180px; background: radial-gradient(circle, rgba(255, 107, 0, .48), transparent 68%); animation: drift1 20s ease-in-out infinite; }
        .aura .a2 { width: 520px; height: 520px; top: -160px; right: -140px; background: radial-gradient(circle, rgba(217, 69, 0, .38), transparent 68%); animation: drift2 26s ease-in-out infinite; }
        .aura .a3 { width: 780px; height: 780px; bottom: -420px; left: 34%; background: radial-gradient(circle, rgba(255, 161, 74, .18), transparent 70%); animation: drift1 30s ease-in-out infinite reverse; }

        @keyframes drift1 { 0%, 100% { transform: translate3d(0, 0, 0) scale(1); } 50% { transform: translate3d(46px, 34px, 0) scale(1.07); } }
        @keyframes drift2 { 0%, 100% { transform: translate3d(0, 0, 0) scale(1); } 50% { transform: translate3d(-52px, 28px, 0) scale(1.05); } }

        .glass {
            background: var(--glass);
            backdrop-filter: blur(28px) saturate(160%);
            -webkit-backdrop-filter: blur(28px) saturate(160%);
            border: 1px solid var(--line);
            box-shadow: var(--shadow);
        }

        /* ---------- 3. LAYOUT ---------- */
        .app {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: var(--side) minmax(0, 1fr);
            min-height: 100vh;
        }

        .workspace { min-width: 0; display: flex; flex-direction: column; }

        /* ---------- 4. SIDEBAR ---------- */
        .sidebar {
            position: sticky;
            top: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            gap: 28px;
            padding: 22px 14px calc(var(--player) + 14px);
            background: linear-gradient(180deg, rgba(28, 19, 14, .74), rgba(10, 8, 7, .9));
            backdrop-filter: blur(28px) saturate(150%);
            -webkit-backdrop-filter: blur(28px) saturate(150%);
            border-right: 1px solid var(--line);
        }

        .brand { display: flex; align-items: center; gap: 12px; padding: 2px 10px; }
        .brand-mark {
            width: 40px; height: 40px; border-radius: 13px; flex: none;
            display: grid; place-items: center;
            background: var(--grad); color: #fff;
            box-shadow: var(--glow), inset 0 1px 0 rgba(255, 255, 255, .4);
        }
        .brand-mark svg { width: 21px; height: 21px; }
        .brand-text { display: flex; flex-direction: column; line-height: 1.1; }
        .brand-name { font-family: "Outfit", sans-serif; font-size: 17px; font-weight: 700; letter-spacing: -.02em; }
        .brand-sub { font-size: 9.5px; letter-spacing: .2em; text-transform: uppercase; color: var(--muted-dim); font-weight: 600; }

        .nav { display: flex; flex-direction: column; gap: 3px; }
        .nav-label {
            font-size: 9.5px; letter-spacing: .2em; text-transform: uppercase;
            color: var(--muted-dim); font-weight: 700; padding: 0 12px 9px;
        }
        .nav-link {
            position: relative;
            display: flex; align-items: center; gap: 12px;
            padding: 11px 12px; border-radius: var(--r-sm);
            color: var(--muted); font-size: 14px; font-weight: 500;
            border: 1px solid transparent;
            transition: color .2s var(--ease), background .2s var(--ease), transform .2s var(--ease);
        }
        .nav-link svg { width: 18px; height: 18px; flex: none; opacity: .9; }
        .nav-link:hover { color: var(--text); background: rgba(255, 255, 255, .05); transform: translateX(2px); }
        .nav-link.is-active {
            color: #fff;
            background: var(--grad-soft);
            border-color: rgba(255, 107, 0, .26);
        }
        .nav-link.is-active svg { color: var(--brand-light); opacity: 1; }
        .nav-link.is-active::before {
            content: ""; position: absolute; left: -14px; top: 50%;
            transform: translateY(-50%);
            width: 3px; height: 20px; border-radius: 0 3px 3px 0;
            background: var(--brand); box-shadow: 0 0 16px rgba(255, 107, 0, .9);
        }
        .nav-link.is-soon { opacity: .45; cursor: default; }
        .nav-link.is-soon:hover { transform: none; background: none; color: var(--muted); }
        .nav-badge {
            margin-left: auto; font-size: 8.5px; font-weight: 700; letter-spacing: .08em;
            text-transform: uppercase; color: var(--brand-light);
            background: rgba(255, 107, 0, .13); padding: 2px 7px; border-radius: 99px;
        }

        .side-foot { margin-top: auto; }
        .hint-card {
            border: 1px solid var(--line); border-radius: var(--r-md);
            padding: 14px 15px; background: var(--glass);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
        }
        .hint-card h4 { font-size: 12.5px; margin-bottom: 6px; }
        .hint-card p { font-size: 11.5px; color: var(--muted); line-height: 1.6; }
        .hint-row { display: flex; align-items: center; gap: 7px; margin-top: 10px; font-size: 11px; color: var(--brand-light); font-weight: 600; }
        .hint-row svg { width: 13px; height: 13px; }

        kbd {
            display: inline-block; min-width: 18px; text-align: center;
            font-family: inherit; font-size: 10px; font-weight: 700;
            background: rgba(255, 255, 255, .09); border: 1px solid var(--line-2);
            border-bottom-width: 2px; border-radius: 5px; padding: 0 5px;
            color: var(--text); line-height: 1.5;
        }

        /* ---------- 5. TOPBAR ---------- */
        .topbar {
            position: sticky; top: 0; z-index: 40;
            display: flex; align-items: center; gap: 18px; flex-wrap: wrap;
            min-height: var(--top);
            padding: 12px 28px;
            background: rgba(12, 9, 8, .6);
            backdrop-filter: blur(26px) saturate(170%);
            -webkit-backdrop-filter: blur(26px) saturate(170%);
            border-bottom: 1px solid var(--line);
        }

        .crumbs { display: flex; align-items: center; gap: 9px; font-size: 12.5px; color: var(--muted-dim); }
        .crumbs strong { color: var(--text); font-weight: 600; }
        .crumbs .sep { opacity: .5; }

        .top-tools { margin-left: auto; display: flex; align-items: center; gap: 10px; }

        .search { position: relative; display: flex; align-items: center; }
        .search svg { position: absolute; left: 12px; width: 15px; height: 15px; color: var(--muted-dim); pointer-events: none; }
        .search input {
            width: 260px; max-width: 42vw;
            padding: 9px 40px 9px 36px;
            border-radius: 11px;
            background: rgba(255, 255, 255, .05);
            border: 1px solid var(--line);
            color: var(--text); font-size: 13px; font-family: inherit;
            transition: border-color .2s, box-shadow .2s, background .2s;
        }
        .search input::placeholder { color: var(--muted-dim); }
        .search input:focus {
            outline: none; border-color: rgba(255, 107, 0, .55);
            background: rgba(255, 107, 0, .06);
            box-shadow: 0 0 0 3px rgba(255, 107, 0, .13);
        }
        .search kbd { position: absolute; right: 9px; pointer-events: none; }

        .user-chip {
            display: flex; align-items: center; gap: 10px;
            padding: 5px 13px 5px 5px; border-radius: 99px;
            background: rgba(255, 255, 255, .05);
            border: 1px solid var(--line);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            transition: border-color .2s, background .2s;
        }
        .user-chip:hover { border-color: rgba(255, 107, 0, .35); background: rgba(255, 107, 0, .07); }

        .avatar {
            width: 32px; height: 32px; border-radius: 50%; flex: none;
            display: grid; place-items: center; overflow: hidden;
            background: var(--grad); color: #fff;
            font-size: 12px; font-weight: 700;
            box-shadow: 0 0 0 2px rgba(255, 107, 0, .22);
        }
        .avatar img { width: 100%; height: 100%; object-fit: cover; }

        .user-meta { display: flex; flex-direction: column; line-height: 1.2; min-width: 0; }
        .user-name { font-size: 12.5px; font-weight: 600; max-width: 190px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .user-role { font-size: 9.5px; letter-spacing: .09em; text-transform: uppercase; color: var(--brand-light); font-weight: 700; }

        /* ---------- BOTONES ---------- */
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            padding: 11px 17px; border-radius: var(--r-sm);
            font-size: 13.5px; font-weight: 600; line-height: 1; white-space: nowrap;
            border: 1px solid transparent;
            transition: transform .18s var(--spring), background .2s, border-color .2s, box-shadow .25s, color .2s;
        }
        .btn svg { width: 16px; height: 16px; }
        .btn:active { transform: scale(.97); }
        .btn-primary {
            background: var(--grad); color: #fff;
            box-shadow: 0 12px 28px -14px rgba(255, 107, 0, .95), inset 0 1px 0 rgba(255, 255, 255, .32);
        }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 18px 36px -14px rgba(255, 107, 0, 1); }
        .btn-ghost { background: rgba(255, 255, 255, .05); color: var(--muted); border-color: var(--line); }
        .btn-ghost:hover { color: var(--text); background: rgba(255, 255, 255, .085); border-color: var(--line-2); }
        .btn-danger { background: rgba(255, 107, 107, .13); color: #FF9B9B; border-color: rgba(255, 107, 107, .3); }
        .btn-danger:hover { background: rgba(255, 107, 107, .21); color: #FFC4C4; }
        .btn-sm { padding: 9px 13px; font-size: 12.5px; border-radius: 11px; }

        .icon-btn {
            width: 34px; height: 34px; border-radius: 10px; padding: 0; flex: none;
            display: inline-grid; place-items: center;
            background: rgba(255, 255, 255, .045);
            border: 1px solid var(--line);
            color: var(--muted);
            transition: color .18s, background .18s, border-color .18s, transform .18s var(--spring);
        }
        .icon-btn svg { width: 16px; height: 16px; }
        .icon-btn:hover { color: var(--text); background: rgba(255, 255, 255, .09); border-color: var(--line-2); transform: translateY(-1px); }
        .icon-btn.is-danger:hover { color: #FFB4B4; background: rgba(255, 107, 107, .15); border-color: rgba(255, 107, 107, .34); }
        .icon-btn.is-play { color: var(--brand-light); background: rgba(255, 107, 0, .1); border-color: rgba(255, 107, 0, .24); }
        .icon-btn.is-play:hover { color: #fff; background: var(--grad); border-color: transparent; box-shadow: var(--glow); }
        .icon-btn[disabled] { opacity: .3; cursor: not-allowed; transform: none; }
        .icon-btn[disabled]:hover { color: var(--muted); background: rgba(255, 255, 255, .045); border-color: var(--line); box-shadow: none; }

        /* ---------- CONTENIDO ---------- */
        .content {
            flex: 1;
            width: 100%;
            max-width: 1380px;
            margin: 0 auto;
            padding: 22px 28px calc(var(--player) + 44px);
            display: flex; flex-direction: column; gap: 16px;
        }

        /* ---------- 6. HERO ---------- */
        .hero {
            position: relative;
            display: flex; align-items: center; gap: 28px;
            padding: 26px 30px;
            border-radius: var(--r-xl);
            overflow: hidden;
        }
        .hero::after {
            content: ""; position: absolute; inset: 0; pointer-events: none;
            background: radial-gradient(560px 240px at 86% 6%, rgba(255, 107, 0, .2), transparent 72%);
        }
        .hero-copy { position: relative; z-index: 1; display: flex; flex-direction: column; gap: 9px; min-width: 0; }

        .eyebrow {
            display: inline-flex; align-items: center; gap: 8px;
            font-size: 10px; font-weight: 700; letter-spacing: .2em; text-transform: uppercase;
            color: var(--brand-light);
        }
        .eyebrow .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--brand); box-shadow: 0 0 12px rgba(255, 107, 0, .95); }

        .hero h1 { font-size: 36px; font-weight: 700; letter-spacing: -.04em; line-height: 1.04; }
        .hero h1 em {
            font-style: normal;
            background: var(--grad);
            -webkit-background-clip: text; background-clip: text;
            -webkit-text-fill-color: transparent; color: transparent;
        }
        .hero-sub { font-size: 13.5px; color: var(--muted); max-width: 580px; line-height: 1.65; }
        .hero-sub strong { color: var(--text); font-weight: 600; }
        .hero-actions { display: flex; align-items: center; gap: 10px; margin-top: 6px; flex-wrap: wrap; }

        .hero-art { position: relative; z-index: 1; margin-left: auto; flex: none; }

        .disc {
            position: relative;
            width: 140px; height: 140px; border-radius: 50%;
            background:
                radial-gradient(circle at 32% 26%, rgba(255, 255, 255, .16), transparent 46%),
                repeating-radial-gradient(circle at 50% 50%, #191110 0 2px, #0D0908 2px 5px);
            box-shadow: 0 24px 60px -26px rgba(0, 0, 0, 1), inset 0 0 0 1px rgba(255, 255, 255, .07);
            display: grid; place-items: center;
            animation: spin 22s linear infinite;
        }
        .disc::before {
            content: ""; position: absolute; inset: 0; border-radius: 50%;
            background: conic-gradient(from 210deg, transparent 0 62%, rgba(255, 161, 74, .26) 78%, transparent 92%);
        }
        .disc-label {
            position: relative;
            width: 54px; height: 54px; border-radius: 50%;
            display: grid; place-items: center;
            background: var(--grad); color: #fff; font-size: 21px;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, .4), 0 8px 22px -8px rgba(0, 0, 0, .9);
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* ---------- 7. STATS ---------- */
        .stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; }
        .stat {
            padding: 13px 16px; border-radius: var(--r-md);
            display: flex; flex-direction: column; gap: 7px;
            transition: transform .25s var(--ease), border-color .25s;
        }
        .stat:hover { transform: translateY(-2px); border-color: rgba(255, 107, 0, .28); }
        .stat-top {
            display: flex; align-items: center; gap: 8px;
            font-size: 10.5px; font-weight: 600; letter-spacing: .12em; text-transform: uppercase;
            color: var(--muted);
        }
        .stat-top svg { width: 14px; height: 14px; color: var(--brand-light); }
        .stat-value {
            font-family: "Outfit", sans-serif; font-size: 24px; font-weight: 700;
            letter-spacing: -.03em; line-height: 1; font-variant-numeric: tabular-nums;
        }

        /* ---------- 8. LISTA ---------- */
        .panel {
            border-radius: var(--r-lg);
            padding: 22px 24px 24px;
            display: flex; flex-direction: column; gap: 15px;
        }
        .panel-head { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .panel-title { display: flex; align-items: center; gap: 10px; }
        .panel-title h2 { font-size: 17.5px; }
        .chip {
            font-size: 10px; font-weight: 700; letter-spacing: .07em; text-transform: uppercase;
            color: var(--brand-light); background: rgba(255, 107, 0, .12);
            border: 1px solid rgba(255, 107, 0, .2);
            padding: 3px 9px; border-radius: 99px; white-space: nowrap;
        }
        .panel-tools { margin-left: auto; display: flex; align-items: center; gap: 8px; }

        .track-head, .track {
            display: grid;
            grid-template-columns: 42px 48px minmax(0, 1fr) 108px 150px;
            align-items: center;
            gap: 14px;
        }
        .track-head {
            padding: 0 12px 9px;
            font-size: 10px; font-weight: 700; letter-spacing: .16em; text-transform: uppercase;
            color: var(--muted-dim);
            border-bottom: 1px solid var(--line);
        }
        .track-head .col-end { text-align: right; }
        .track-head > span:first-child { text-align: center; }

        .track {
            position: relative;
            padding: 8px 12px;
            border-radius: var(--r-sm);
            border: 1px solid transparent;
            transition: background .2s var(--ease), border-color .2s, transform .2s var(--ease);
        }
        .track + .track { margin-top: 2px; }
        .track:hover { background: rgba(255, 255, 255, .055); border-color: var(--line); }
        .track.is-playing { background: var(--grad-soft); border-color: rgba(255, 107, 0, .3); }
        .track.is-playing .track-name { color: #fff; }

        .track-index { font-size: 11.5px; color: var(--muted-dim); text-align: center; font-variant-numeric: tabular-nums; }
        .track.is-playing .track-index { color: var(--brand-light); }

        .cover {
            position: relative; flex: none;
            width: 48px; height: 48px; border-radius: 12px;
            display: grid; place-items: center; overflow: hidden;
            font-family: "Outfit", sans-serif; font-size: 17px; font-weight: 700; color: #fff;
            background: linear-gradient(135deg, #FFA14A, #D94500);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, .3), 0 10px 20px -14px rgba(0, 0, 0, .95);
        }
        .track:nth-child(6n+2) .cover { background: linear-gradient(135deg, #FFB020, #C74900); }
        .track:nth-child(6n+3) .cover { background: linear-gradient(135deg, #FF7A45, #A33B48); }
        .track:nth-child(6n+4) .cover { background: linear-gradient(135deg, #F48C06, #7A2E0E); }
        .track:nth-child(6n+5) .cover { background: linear-gradient(135deg, #FFC24B, #E8590C); }
        .track:nth-child(6n+6) .cover { background: linear-gradient(135deg, #FFA14A, #8C3300); }

        .eq { display: none; position: absolute; inset: 0; align-items: flex-end; justify-content: center; gap: 2px; padding-bottom: 12px; background: rgba(10, 7, 6, .58); }
        .track.is-playing .eq { display: flex; }
        .eq i { display: block; width: 2.5px; height: 10px; border-radius: 2px; background: #fff; animation: eq 1s ease-in-out infinite; }
        .eq i:nth-child(2) { animation-delay: .16s; }
        .eq i:nth-child(3) { animation-delay: .32s; }
        @keyframes eq { 0%, 100% { height: 4px; } 50% { height: 13px; } }

        .track-text { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .track-name {
            display: flex; align-items: center; gap: 8px;
            font-size: 13.5px; font-weight: 600;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .track-file {
            font-size: 11.5px; color: var(--muted-dim);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .flag {
            display: inline-flex; align-items: center; gap: 4px; flex: none;
            font-size: 9px; font-weight: 700; letter-spacing: .07em; text-transform: uppercase;
            color: #FFC24B; background: rgba(255, 194, 75, .12);
            border: 1px solid rgba(255, 194, 75, .26);
            padding: 1px 7px; border-radius: 99px;
        }
        .flag svg { width: 10px; height: 10px; }

        .col-plays { font-size: 12.5px; color: var(--muted); text-align: right; padding-right: 10px; font-variant-numeric: tabular-nums; }
        .track-head .col-plays { font-size: 10px; font-weight: 700; color: var(--muted-dim); }

        .row-actions { display: flex; align-items: center; justify-content: flex-end; gap: 5px; }

        .link-action {
            font-size: 10px; font-weight: 700; letter-spacing: .07em; text-transform: uppercase;
            color: var(--muted-dim); padding: 7px 9px; border-radius: 9px;
            border: 1px solid transparent; white-space: nowrap;
            transition: color .18s, background .18s, border-color .18s;
        }
        .link-action:hover { color: var(--brand-light); background: rgba(255, 107, 0, .1); border-color: rgba(255, 107, 0, .24); }
        .link-action.is-danger:hover { color: #FFB4B4; background: rgba(255, 107, 107, .13); border-color: rgba(255, 107, 107, .28); }

        /* Estado vacío */
        .empty { display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 50px 20px; text-align: center; }
        .empty[hidden] { display: none; }
        .empty-icon {
            width: 56px; height: 56px; border-radius: var(--r-md); display: grid; place-items: center;
            background: rgba(255, 107, 0, .11); border: 1px solid rgba(255, 107, 0, .22);
            color: var(--brand-light); margin-bottom: 4px;
        }
        .empty-icon svg { width: 25px; height: 25px; }
        .empty h3 { font-size: 16.5px; }
        .empty p { font-size: 13px; color: var(--muted); max-width: 380px; line-height: 1.6; }
        .empty .btn { margin-top: 8px; }

        .foot {
            display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
            font-size: 11.5px; color: var(--muted-dim); padding: 0 6px 4px;
        }
        .foot .sep { width: 3px; height: 3px; border-radius: 50%; background: currentColor; opacity: .55; }

        /* ---------- 9. REPRODUCTOR ---------- */
        .player {
            position: fixed; left: 0; right: 0; bottom: 0; z-index: 60;
            height: var(--player);
            display: grid;
            grid-template-columns: minmax(190px, 1fr) minmax(300px, 2fr) minmax(150px, 1fr);
            align-items: center; gap: 20px;
            padding: 0 24px;
            background: rgba(16, 11, 9, .74);
            backdrop-filter: blur(30px) saturate(175%);
            -webkit-backdrop-filter: blur(30px) saturate(175%);
            border-top: 1px solid var(--line-2);
            box-shadow: 0 -26px 60px -36px rgba(0, 0, 0, 1);
        }
        .player::before {
            content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 107, 0, .65), transparent);
        }
        .player-track { display: flex; align-items: center; gap: 12px; min-width: 0; }
        .player .cover { width: 54px; height: 54px; border-radius: 13px; font-size: 19px; }
        .player-meta { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .player-title { font-size: 13px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .player-sub { font-size: 11px; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .player-center { display: flex; flex-direction: column; align-items: center; gap: 7px; }
        .controls { display: flex; align-items: center; gap: 12px; }
        .pc {
            width: 34px; height: 34px; border-radius: 50%;
            display: grid; place-items: center; color: var(--muted);
            transition: color .18s, transform .18s var(--spring), background .18s;
        }
        .pc svg { width: 17px; height: 17px; }
        .pc:hover { color: var(--text); background: rgba(255, 255, 255, .07); }
        .pc:active { transform: scale(.92); }
        .pc.is-primary {
            width: 44px; height: 44px; color: #fff; background: var(--grad);
            box-shadow: 0 12px 28px -14px rgba(255, 107, 0, 1), inset 0 1px 0 rgba(255, 255, 255, .32);
        }
        .pc.is-primary svg { width: 19px; height: 19px; }
        .pc.is-primary:hover { transform: scale(1.06); color: #fff; }

        .timeline { display: flex; align-items: center; gap: 9px; width: 100%; max-width: 520px; }
        .timeline span { font-size: 10.5px; color: var(--muted-dim); font-variant-numeric: tabular-nums; min-width: 32px; text-align: center; }

        input[type=range] {
            -webkit-appearance: none; appearance: none;
            width: 100%; height: 4px; border-radius: 99px; outline: none; cursor: pointer;
            background: linear-gradient(to right, var(--brand) 0%, var(--brand) calc(var(--p, 0) * 1%), rgba(255, 255, 255, .16) calc(var(--p, 0) * 1%), rgba(255, 255, 255, .16) 100%);
        }
        input[type=range]::-webkit-slider-thumb {
            -webkit-appearance: none; appearance: none;
            width: 12px; height: 12px; border-radius: 50%; background: #fff;
            box-shadow: 0 0 0 4px rgba(255, 107, 0, .2), 0 2px 6px rgba(0, 0, 0, .55);
            transition: transform .15s;
        }
        input[type=range]:hover::-webkit-slider-thumb { transform: scale(1.15); }
        input[type=range]::-moz-range-thumb {
            width: 12px; height: 12px; border: 0; border-radius: 50%; background: #fff;
            box-shadow: 0 0 0 4px rgba(255, 107, 0, .2);
        }

        .player-right { display: flex; align-items: center; gap: 8px; justify-content: flex-end; }
        .player-right input[type=range] { max-width: 92px; }

        /* ---------- 10. MODALES ---------- */
        .modal { position: fixed; inset: 0; z-index: 100; display: none; align-items: center; justify-content: center; padding: 20px; }
        .modal.is-open { display: flex; }
        .modal-backdrop { position: absolute; inset: 0; background: rgba(6, 4, 3, .66); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }

        .modal-card {
            position: relative;
            width: 100%; max-width: 500px; max-height: calc(100vh - 40px); overflow-y: auto;
            padding: 24px; border-radius: var(--r-lg);
            background: linear-gradient(168deg, rgba(40, 28, 21, .97), rgba(15, 11, 9, .99));
            border: 1px solid var(--line-2);
            box-shadow: 0 46px 110px -36px rgba(0, 0, 0, 1), inset 0 1px 0 rgba(255, 255, 255, .1);
            animation: pop .28s var(--spring);
        }
        @keyframes pop { from { opacity: 0; transform: translateY(14px) scale(.975); } to { opacity: 1; transform: none; } }

        .modal-head { display: flex; align-items: flex-start; gap: 13px; margin-bottom: 20px; }
        .modal-head h3 { font-size: 17.5px; }
        .modal-head p { font-size: 12.5px; color: var(--muted); margin-top: 4px; line-height: 1.55; }
        .modal-head .icon-btn { margin-left: auto; flex: none; }
        .modal-icon {
            width: 40px; height: 40px; border-radius: 13px; flex: none;
            display: grid; place-items: center;
            background: rgba(255, 107, 0, .12); border: 1px solid rgba(255, 107, 0, .24);
            color: var(--brand-light);
        }
        .modal-icon svg { width: 19px; height: 19px; }
        .modal-icon.is-danger { background: rgba(255, 107, 107, .12); border-color: rgba(255, 107, 107, .28); color: #FF9B9B; }

        .field { margin-bottom: 15px; }
        .field label {
            display: flex; align-items: center; justify-content: space-between; gap: 8px;
            font-size: 12px; font-weight: 600; color: var(--muted); margin-bottom: 7px;
        }
        .field label .req { color: var(--brand-light); }
        .field .hint { font-size: 10.5px; color: var(--muted-dim); font-weight: 500; }

        .field input[type=text], .field input[type=file] {
            width: 100%; padding: 11px 13px; border-radius: 11px;
            background: rgba(255, 255, 255, .045);
            border: 1px solid var(--line);
            color: var(--text); font-size: 13.5px; font-family: inherit;
            transition: border-color .2s, box-shadow .2s, background .2s;
        }
        .field input::placeholder { color: var(--muted-dim); }
        .field input[type=text]:focus {
            outline: none; border-color: rgba(255, 107, 0, .55);
            background: rgba(255, 107, 0, .06);
            box-shadow: 0 0 0 3px rgba(255, 107, 0, .13);
        }
        .field input[type=file] { padding: 8px 11px; font-size: 12.5px; color: var(--muted); }
        .field input[type=file]::file-selector-button {
            margin-right: 11px; padding: 6px 11px; border-radius: 8px;
            border: 1px solid var(--line-2); background: rgba(255, 255, 255, .07);
            color: var(--text); font-family: inherit; font-size: 11.5px; font-weight: 600; cursor: pointer;
        }
        .field-note { font-size: 11px; color: var(--muted-dim); margin-top: 6px; line-height: 1.55; }

        .form-alert {
            display: flex; align-items: flex-start; gap: 9px;
            padding: 11px 13px; border-radius: 11px; margin-bottom: 15px;
            background: rgba(255, 107, 107, .1); border: 1px solid rgba(255, 107, 107, .28);
            font-size: 12.5px; color: #FFB8B8; line-height: 1.5;
        }
        .form-alert svg { width: 15px; height: 15px; flex: none; margin-top: 2px; color: #FF9B9B; }

        .modal-foot { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; flex-wrap: wrap; }
        .modal-foot .btn { min-width: 104px; }
        .modal-foot input[type=submit] { -webkit-appearance: none; appearance: none; }

        /* ---------- 11. TOASTS ---------- */
        .toasts {
            position: fixed; right: 20px; bottom: calc(var(--player) + 16px); z-index: 120;
            display: flex; flex-direction: column; gap: 9px; pointer-events: none;
        }
        .toast {
            display: flex; align-items: flex-start; gap: 10px;
            min-width: 250px; max-width: 370px; padding: 12px 14px;
            border-radius: 13px;
            background: rgba(34, 25, 20, .96);
            border: 1px solid var(--line-2);
            box-shadow: 0 22px 48px -22px rgba(0, 0, 0, 1);
            backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
            pointer-events: auto;
            animation: toastIn .3s var(--spring);
        }
        @keyframes toastIn { from { opacity: 0; transform: translateX(18px); } to { opacity: 1; transform: none; } }
        .toast .t-icon { width: 25px; height: 25px; border-radius: 8px; flex: none; display: grid; place-items: center; }
        .toast .t-icon svg { width: 14px; height: 14px; }
        .toast.is-success .t-icon { background: rgba(53, 211, 153, .14); color: var(--ok); }
        .toast.is-error .t-icon { background: rgba(255, 107, 107, .14); color: #FF9B9B; }
        .toast.is-info .t-icon { background: rgba(255, 107, 0, .14); color: var(--brand-light); }
        .toast .t-body { display: flex; flex-direction: column; gap: 1px; min-width: 0; }
        .toast .t-title { font-size: 12.5px; font-weight: 600; }
        .toast .t-msg { font-size: 11.5px; color: var(--muted); line-height: 1.45; }

        /* ---------- 12. RESPONSIVE ---------- */
        @media (max-width: 1180px) {
            .hero h1 { font-size: 34px; }
            .disc { width: 128px; height: 128px; }
            .disc-label { width: 50px; height: 50px; font-size: 20px; }
            .track-head, .track { grid-template-columns: 36px 46px minmax(0, 1fr) 84px 142px; gap: 11px; }
        }

        @media (max-width: 1000px) {
            .app { grid-template-columns: minmax(0, 1fr); }
            .sidebar { display: none; }
            .content { padding: 18px 16px calc(var(--player) + 26px); }
            .topbar { padding: 11px 16px; gap: 12px; }
            .search input { width: 200px; }
            .track-head, .track { grid-template-columns: 32px 46px minmax(0, 1fr) 128px; }
            .track-head .col-plays, .track .col-plays { display: none; }
        }

        @media (max-width: 900px) {
            .top-tools .search { display: none; }
        }

        @media (max-width: 760px) {
            .hero { flex-direction: column; align-items: flex-start; padding: 24px; gap: 18px; }
            .hero-art { display: none; }
            .hero h1 { font-size: 28px; }
            .stats { grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; }
            .stat { padding: 12px 12px; gap: 6px; border-radius: var(--r-sm); }
            .stat-top { font-size: 8.5px; letter-spacing: .07em; gap: 5px; }
            .stat-top svg { width: 12px; height: 12px; }
            .stat-top span { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
            .stat-value { font-size: 20px; }
            .panel { padding: 18px 14px; }
            .panel-tools { width: 100%; margin-left: 0; }
            .panel-tools .search { width: 100%; }
            .panel-tools .search input { width: 100%; max-width: none; }
            .track-head { display: none; }
            .track { grid-template-columns: 30px 44px minmax(0, 1fr) 84px; }
            .link-action { display: none; }
            .user-meta { display: none; }
            .player { grid-template-columns: minmax(0, 1fr) auto; padding: 0 14px; gap: 10px; }
            .player-center .timeline { display: none; }
            .player-right { display: none; }
            .foot { display: none; }
        }

        @media (max-width: 420px) {
            .hero h1 { font-size: 25px; }
            .content { padding-left: 12px; padding-right: 12px; }
            .topbar { padding: 10px 12px; }
            .stat { padding: 11px 10px; }
            .stat-top { font-size: 8px; letter-spacing: .03em; }
            .stat-top svg { display: none; }
            .track { grid-template-columns: 26px 42px minmax(0, 1fr) 40px; gap: 10px; }
            .track .icon-btn { width: 32px; height: 32px; }
        }
    </style>
</head>
<body>
    <div class="aura" aria-hidden="true"><i class="a1"></i><i class="a2"></i><i class="a3"></i></div>

    <form id="form1" runat="server">
        <div class="app">

            <!-- ==================== SIDEBAR ==================== -->
            <aside class="sidebar">
                <a class="brand" href="Default.aspx" title="PoliMusic">
                    <span class="brand-mark">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                    </span>
                    <span class="brand-text">
                        <span class="brand-name">PoliMusic</span>
                        <span class="brand-sub">Web App</span>
                    </span>
                </a>

                <nav class="nav" aria-label="Navegación principal">
                    <span class="nav-label">Descubrir</span>
                    <a class="nav-link" href="Default.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V21h14V9.5" /></svg>
                        <span>Inicio</span>
                    </a>
                    <a class="nav-link is-active" href="Song.aspx" aria-current="page">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                        <span>Canciones</span>
                    </a>
                    <span class="nav-link is-soon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1.6" /><rect x="14" y="3" width="7" height="7" rx="1.6" /><rect x="3" y="14" width="7" height="7" rx="1.6" /><rect x="14" y="14" width="7" height="7" rx="1.6" /></svg>
                        <span>Playlists</span><span class="nav-badge">Pronto</span>
                    </span>
                    <span class="nav-link is-soon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15a4 4 0 0 0 4-4V6a4 4 0 0 0-8 0v5a4 4 0 0 0 4 4Z" /><path d="M19 11a7 7 0 0 1-14 0" /><path d="M12 18v3" /></svg>
                        <span>Artistas</span><span class="nav-badge">Pronto</span>
                    </span>
                </nav>

                <div class="side-foot">
                    <div class="hint-card">
                        <h4>Atajos</h4>
                        <p>Busca con <kbd>/</kbd>, reproduce o pausa con <kbd>espacio</kbd>.</p>
                        <span class="hint-row">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12h16" /><path d="m14 6 6 6-6 6" /></svg>
                            Reproducción continua
                        </span>
                    </div>
                </div>
            </aside>

            <!-- ==================== WORKSPACE ==================== -->
            <div class="workspace">
                <header class="topbar">
                    <div class="crumbs">
                        <span>Biblioteca</span>
                        <span class="sep">/</span>
                        <strong>Canciones</strong>
                    </div>

                    <div class="top-tools">
                        <div class="search">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                            <input type="search" id="searchInput" placeholder="Buscar canción…" aria-label="Buscar canciones" autocomplete="off" />
                            <kbd>/</kbd>
                        </div>

                        <div class="user-chip" title="Sesión iniciada">
                            <span class="avatar"><asp:Literal ID="litAvatar" runat="server" /></span>
                            <span class="user-meta">
                                <span class="user-name"><asp:Literal ID="litUserName" runat="server" /></span>
                                <span class="user-role"><asp:Literal ID="litUserRole" runat="server" /></span>
                            </span>
                        </div>

                        <asp:HyperLink ID="lnkLogout" runat="server" CssClass="btn btn-ghost btn-sm" NavigateUrl="~/Logout.aspx" Text="Salir" />
                    </div>
                </header>

                <main class="content">

                    <!-- HERO -->
                    <section class="hero glass">
                        <div class="hero-copy">
                            <span class="eyebrow"><span class="dot"></span>Tu biblioteca</span>
                            <h1>Escucha tu <em>catálogo</em></h1>
                            <p class="hero-sub">
                                Hola <strong><asp:Literal ID="litHeroName" runat="server" /></strong>, estas son todas las
                                canciones registradas en <strong>TBL_SONG</strong>. Elige una pista de la lista y empieza a sonar.
                            </p>
                            <div class="hero-actions">
                                <button type="button" class="btn btn-primary" id="btnPlayAll">
                                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                                    Reproducir todo
                                </button>
                                <asp:Button ID="btnNew" runat="server" CssClass="btn btn-ghost" Text="+ Nueva canción" OnClick="btnNew_Click" CausesValidation="false" />
                            </div>
                        </div>

                        <div class="hero-art" aria-hidden="true">
                            <div class="disc"><span class="disc-label">&#9834;</span></div>
                        </div>
                    </section>

                    <!-- STATS -->
                    <section class="stats" aria-label="Resumen del catálogo">
                        <article class="stat glass">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                                <span>Canciones</span>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatSongs" runat="server" /></div>
                        </article>
                        <article class="stat glass">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 5.5v13l10-6.5-10-6.5Z" /></svg>
                                <span>Reproducciones</span>
                            </div>
                            <div class="stat-value"><span id="statPlays"><asp:Literal ID="litStatPlays" runat="server" /></span></div>
                        </article>
                        <article class="stat glass">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H3v6h3l5 4V5Z" /><path d="M16 9a4 4 0 0 1 0 6" /></svg>
                                <span>Con audio</span>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatAudio" runat="server" /></div>
                        </article>
                    </section>

                    <!-- LISTA -->
                    <section class="panel glass">
                        <div class="panel-head">
                            <div class="panel-title">
                                <h2>Canciones</h2>
                                <span class="chip"><asp:Literal ID="litCountChip" runat="server" /></span>
                            </div>
                            <div class="panel-tools">
                                <div class="search">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                                    <input type="search" id="searchInline" placeholder="Filtrar por nombre…" aria-label="Filtrar canciones" autocomplete="off" />
                                </div>
                            </div>
                        </div>

                        <div class="track-head" aria-hidden="true">
                            <span>#</span>
                            <span></span>
                            <span>Canción</span>
                            <span class="col-plays">Reproducciones</span>
                            <span class="col-end">Acciones</span>
                        </div>

                        <asp:Repeater ID="rptSongs" runat="server" OnItemCommand="rptSongs_ItemCommand">
                            <ItemTemplate>
                                <div class="track"
                                    data-id='<%# AttrEncode(Eval("ID_SONG")) %>'
                                    data-name='<%# AttrEncode(Eval("SONG_NAME")) %>'
                                    data-src='<%# AttrEncode(SongUrl(Eval("SONG_PATH"))) %>'
                                    data-available='<%# IsAvailable(Eval("SONG_PATH")) %>'
                                    data-plays='<%# AttrEncode(Eval("PLAYS")) %>'>
                                    <span class="track-index"><%# RowNumber(Container.ItemIndex) %></span>

                                    <div class="cover" aria-hidden="true">
                                        <span><%# SongInitial(Eval("SONG_NAME")) %></span>
                                        <span class="eq"><i></i><i></i><i></i></span>
                                    </div>

                                    <div class="track-text">
                                        <span class="track-name">
                                            <%# HtmlText(Eval("SONG_NAME")) %>
                                            <%# MissingFlag(Eval("SONG_PATH")) %>
                                        </span>
                                        <span class="track-file"><%# FileName(Eval("SONG_PATH")) %></span>
                                    </div>

                                    <span class="col-plays" data-plays-cell><%# PlaysText(Eval("PLAYS")) %></span>

                                    <div class="row-actions">
                                        <button type="button" class="icon-btn is-play" data-play title="Reproducir" aria-label="Reproducir">
                                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                                        </button>
                                        <asp:LinkButton ID="lnkEdit" runat="server" CssClass="link-action" CommandName="edit" CommandArgument='<%# Eval("ID_SONG") %>' Text="Editar" CausesValidation="false" />
                                        <asp:LinkButton ID="lnkDelete" runat="server" CssClass="link-action is-danger" CommandName="delete" CommandArgument='<%# Eval("ID_SONG") %>' Text="Eliminar" CausesValidation="false" />
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                            <span class="empty-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                            </span>
                            <h3>Tu catálogo está vacío</h3>
                            <p>Todavía no hay canciones registradas. Agrega la primera para empezar a escuchar música.</p>
                        </asp:Panel>

                        <div class="empty" id="noResults" hidden>
                            <span class="empty-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                            </span>
                            <h3>Sin resultados</h3>
                            <p>No encontramos canciones que coincidan con tu búsqueda.</p>
                            <button type="button" class="btn btn-ghost" id="btnClearSearch">Limpiar filtro</button>
                        </div>
                    </section>

                    <div class="foot">
                        <span>PoliMusic</span>
                        <span class="sep"></span>
                        <span>ASP.NET WebForms · .NET Framework 4.8</span>
                        <span class="sep"></span>
                        <span>SQL Server · TBL_SONG</span>
                    </div>
                </main>
            </div>
        </div>

        <!-- ==================== MODAL FORMULARIO ==================== -->
        <asp:Panel ID="pnlFormModal" runat="server" CssClass="modal">
            <div class="modal-backdrop" data-close="1"></div>
            <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="formTitle">
                <div class="modal-head">
                    <span class="modal-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                    </span>
                    <div>
                        <h3 id="formTitle"><asp:Literal ID="litFormTitle" runat="server" /></h3>
                        <p>Completa los datos de la canción para guardarla en el catálogo.</p>
                    </div>
                    <button type="button" class="icon-btn" data-close="1" aria-label="Cerrar">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                    </button>
                </div>

                <asp:Literal ID="litFormError" runat="server" />
                <asp:HiddenField ID="hfSongId" runat="server" Value="0" />

                <div class="field">
                    <label for="txtSongName">
                        <span>Nombre de la canción <span class="req">*</span></span>
                        <span class="hint">máx. 50</span>
                    </label>
                    <asp:TextBox ID="txtSongName" runat="server" MaxLength="50" />
                </div>

                <div class="field">
                    <label for="txtSongPath">
                        <span>Ruta del archivo <span class="req">*</span></span>
                        <span class="hint">máx. 255</span>
                    </label>
                    <asp:TextBox ID="txtSongPath" runat="server" MaxLength="255" />
                    <datalist id="songFilesList"><asp:Literal ID="litSongFiles" runat="server" /></datalist>
                    <p class="field-note">Ruta lógica dentro del sitio, por ejemplo <code>~/SongFiles/mi-cancion.mp3</code>.</p>
                </div>

                <div class="field">
                    <label for="fuSongFile">
                        <span>Subir archivo MP3</span>
                        <span class="hint">opcional · máx. 50 MB</span>
                    </label>
                    <asp:FileUpload ID="fuSongFile" runat="server" />
                    <p class="field-note">Si subes un archivo, la ruta se actualiza automáticamente con su nombre.</p>
                </div>

                <div class="modal-foot">
                    <button type="button" class="btn btn-ghost" data-close="1">Cancelar</button>
                    <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnSave_Click" />
                </div>
            </div>
        </asp:Panel>

        <!-- ==================== MODAL ELIMINAR ==================== -->
        <asp:Panel ID="pnlDeleteModal" runat="server" CssClass="modal">
            <div class="modal-backdrop" data-close="1"></div>
            <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="deleteTitle" style="max-width: 430px;">
                <div class="modal-head">
                    <span class="modal-icon is-danger">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18" /><path d="M8 6V4h8v2" /><path d="M19 6l-1 14H6L5 6" /><path d="M10 11v5" /><path d="M14 11v5" /></svg>
                    </span>
                    <div>
                        <h3 id="deleteTitle">Eliminar canción</h3>
                        <p>Esta acción no se puede deshacer. La canción también se quitará de las playlists donde aparezca.</p>
                    </div>
                    <button type="button" class="icon-btn" data-close="1" aria-label="Cerrar">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                    </button>
                </div>

                <p style="font-size: 13px; color: var(--muted);">
                    Vas a eliminar <strong style="color: var(--text);"><asp:Literal ID="litDeleteName" runat="server" /></strong> del catálogo.
                </p>

                <asp:HiddenField ID="hfDeleteId" runat="server" Value="0" />

                <div class="modal-foot">
                    <button type="button" class="btn btn-ghost" data-close="1">Cancelar</button>
                    <asp:Button ID="btnConfirmDelete" runat="server" CssClass="btn btn-danger" Text="Eliminar" OnClick="btnConfirmDelete_Click" />
                </div>
            </div>
        </asp:Panel>

        <div class="toasts" aria-live="polite"><asp:Literal ID="litToast" runat="server" /></div>
    </form>

    <!-- ==================== REPRODUCTOR ==================== -->
    <div class="player" role="region" aria-label="Reproductor de audio">
        <div class="player-track">
            <div class="cover" id="playerCover" aria-hidden="true"><span id="playerCoverText">&#9834;</span></div>
            <div class="player-meta">
                <span class="player-title" id="playerTitle">Ninguna canción seleccionada</span>
                <span class="player-sub" id="playerSub">Elige una pista de la lista</span>
            </div>
        </div>

        <div class="player-center">
            <div class="controls">
                <button type="button" class="pc" id="btnPrev" title="Anterior" aria-label="Canción anterior">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 5h2v14H6z" /><path d="M20 5.6v12.8a1 1 0 0 1-1.55.83l-9-6.4a1 1 0 0 1 0-1.66l9-6.4A1 1 0 0 1 20 5.6Z" /></svg>
                </button>
                <button type="button" class="pc is-primary" id="btnPlayPause" title="Reproducir / Pausar" aria-label="Reproducir">
                    <svg viewBox="0 0 24 24" fill="currentColor" id="icoPlay"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                </button>
                <button type="button" class="pc" id="btnNext" title="Siguiente" aria-label="Siguiente canción">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M16 5h2v14h-2z" /><path d="M4 5.6v12.8a1 1 0 0 0 1.55.83l9-6.4a1 1 0 0 0 0-1.66l-9-6.4A1 1 0 0 0 4 5.6Z" /></svg>
                </button>
            </div>
            <div class="timeline">
                <span id="timeCurrent">0:00</span>
                <input type="range" id="seek" min="0" max="100" value="0" step="0.1" aria-label="Progreso de la canción" style="--p: 0" />
                <span id="timeTotal">0:00</span>
            </div>
        </div>

        <div class="player-right">
            <button type="button" class="pc" id="btnMute" title="Silenciar" aria-label="Silenciar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" id="icoVolume"><path d="M11 5 6 9H3v6h3l5 4V5Z" /><path d="M16 9a4 4 0 0 1 0 6" /><path d="M19 6a8 8 0 0 1 0 12" /></svg>
            </button>
            <input type="range" id="volume" min="0" max="1" step="0.01" value="0.8" aria-label="Volumen" style="--p: 80" />
        </div>

        <audio id="pmAudio" preload="metadata"></audio>
    </div>

    <script type="text/javascript">
        (function () {
            "use strict";

            var audio = document.getElementById("pmAudio");
            if (!audio) { return; }

            var ICON_PLAY = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z"/></svg>';
            var ICON_PAUSE = '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="7" y="5" width="3.6" height="14" rx="1.2"/><rect x="13.4" y="5" width="3.6" height="14" rx="1.2"/></svg>';

            var rows = [].slice.call(document.querySelectorAll(".track"));
            var playable = rows.filter(function (row) { return row.getAttribute("data-available") === "1"; });

            var btnPlayPause = document.getElementById("btnPlayPause");
            var btnPrev = document.getElementById("btnPrev");
            var btnNext = document.getElementById("btnNext");
            var btnMute = document.getElementById("btnMute");
            var btnPlayAll = document.getElementById("btnPlayAll");
            var seek = document.getElementById("seek");
            var volume = document.getElementById("volume");
            var timeCurrent = document.getElementById("timeCurrent");
            var timeTotal = document.getElementById("timeTotal");
            var playerTitle = document.getElementById("playerTitle");
            var playerSub = document.getElementById("playerSub");
            var playerCover = document.getElementById("playerCover");
            var playerCoverText = document.getElementById("playerCoverText");

            var COVERS = [
                "linear-gradient(135deg,#FFA14A,#D94500)",
                "linear-gradient(135deg,#FFB020,#C74900)",
                "linear-gradient(135deg,#FF7A45,#A33B48)",
                "linear-gradient(135deg,#F48C06,#7A2E0E)",
                "linear-gradient(135deg,#FFC24B,#E8590C)",
                "linear-gradient(135deg,#FFA14A,#8C3300)"
            ];

            var currentRow = null;
            var countedId = null;

            /* ---------- Utilidades ---------- */
            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { return "0:00"; }
                var total = Math.floor(seconds);
                var minutes = Math.floor(total / 60);
                var rest = total % 60;
                return minutes + ":" + (rest < 10 ? "0" + rest : rest);
            }

            function setFill(element, percent) {
                if (element) { element.style.setProperty("--p", percent); }
            }

            function highlightRow(row) {
                rows.forEach(function (item) { item.classList.remove("is-playing"); });
                if (row) { row.classList.add("is-playing"); }
            }

            function updatePlayIcon(playing) {
                btnPlayPause.innerHTML = playing ? ICON_PAUSE : ICON_PLAY;
                btnPlayPause.setAttribute("aria-label", playing ? "Pausar" : "Reproducir");
            }

            function updatePlaysCell(row, value) {
                if (!row) { return; }
                row.setAttribute("data-plays", value);
                var cell = row.querySelector("[data-plays-cell]");
                if (cell) { cell.textContent = value; }
            }

            /* ---------- Contador de reproducciones (sin recargar la página) ---------- */
            function registerPlay(row) {
                var id = row.getAttribute("data-id");
                if (!id || countedId === id) { return; }
                countedId = id;
                try {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", "SongPlay.ashx?id=" + encodeURIComponent(id), true);
                    xhr.onload = function () {
                        if (xhr.status !== 200) { return; }
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data && data.ok) {
                                updatePlaysCell(row, data.plays);
                                var stat = document.getElementById("statPlays");
                                if (stat) {
                                    stat.textContent = (parseInt(stat.textContent, 10) || 0) + 1;
                                }
                            }
                        } catch (error) { /* respuesta no JSON: se ignora */ }
                    };
                    xhr.send();
                } catch (error) { /* sin conexión: no se bloquea la reproducción */ }
            }

            /* ---------- Reproducción ---------- */
            function startAudio(row) {
                var result = audio.play();
                if (result && typeof result.then === "function") {
                    result.then(function () {
                        updatePlayIcon(true);
                        if (row) { registerPlay(row); }
                    }, function () {
                        updatePlayIcon(false);
                    });
                } else {
                    updatePlayIcon(true);
                    if (row) { registerPlay(row); }
                }
            }

            function loadRow(row, autoplay) {
                if (!row) { return; }
                var src = row.getAttribute("data-src");
                if (!src) { return; }

                currentRow = row;
                countedId = null;
                highlightRow(row);

                var name = row.getAttribute("data-name") || "Canción";
                playerTitle.textContent = name;
                playerSub.textContent = "PoliMusic";
                playerCover.style.background = COVERS[(parseInt(row.getAttribute("data-id"), 10) || 0) % COVERS.length];
                playerCoverText.textContent = name.charAt(0).toUpperCase();
                document.title = name + " · PoliMusic";

                audio.src = src;
                seek.value = 0;
                setFill(seek, 0);
                timeCurrent.textContent = "0:00";
                timeTotal.textContent = "0:00";

                if (autoplay) { startAudio(row); }
            }

            function step(offset) {
                if (playable.length === 0) { return; }
                var index = currentRow ? playable.indexOf(currentRow) : -1;
                if (index < 0) {
                    index = 0;
                } else {
                    index = (index + offset + playable.length) % playable.length;
                }
                loadRow(playable[index], true);
            }

            function togglePlayPause() {
                if (!currentRow) {
                    if (playable.length > 0) { loadRow(playable[0], true); }
                    return;
                }
                if (audio.paused) {
                    startAudio(currentRow);
                } else {
                    audio.pause();
                    updatePlayIcon(false);
                }
            }

            /* ---------- Eventos del reproductor ---------- */
            btnPlayPause.addEventListener("click", togglePlayPause);
            btnPrev.addEventListener("click", function () { step(-1); });
            btnNext.addEventListener("click", function () { step(1); });

            if (btnPlayAll) {
                btnPlayAll.addEventListener("click", function () {
                    if (playable.length === 0) { return; }
                    loadRow(playable[0], true);
                });
            }

            audio.addEventListener("timeupdate", function () {
                if (!audio.duration) { return; }
                var percent = (audio.currentTime / audio.duration) * 100;
                seek.value = percent;
                setFill(seek, percent.toFixed(2));
                timeCurrent.textContent = formatTime(audio.currentTime);
            });
            audio.addEventListener("loadedmetadata", function () {
                timeTotal.textContent = formatTime(audio.duration);
            });
            audio.addEventListener("ended", function () {
                updatePlayIcon(false);
                if (playable.length > 1) { step(1); }
            });
            audio.addEventListener("pause", function () { updatePlayIcon(false); });
            audio.addEventListener("play", function () { updatePlayIcon(true); });
            audio.addEventListener("error", function () {
                updatePlayIcon(false);
                if (currentRow) {
                    playerSub.textContent = "No se pudo cargar el audio";
                }
            });

            seek.addEventListener("input", function () {
                if (!audio.duration) { return; }
                audio.currentTime = (parseFloat(seek.value) / 100) * audio.duration;
                setFill(seek, parseFloat(seek.value).toFixed(2));
            });

            volume.addEventListener("input", function () {
                audio.volume = parseFloat(volume.value);
                audio.muted = audio.volume === 0;
                setFill(volume, (audio.volume * 100).toFixed(0));
            });

            btnMute.addEventListener("click", function () {
                audio.muted = !audio.muted;
                setFill(volume, audio.muted ? 0 : (audio.volume * 100).toFixed(0));
            });

            /* ---------- Botones de play de cada fila ---------- */
            rows.forEach(function (row) {
                var button = row.querySelector("[data-play]");
                if (!button) { return; }
                // Las canciones cuya ruta no existe en el servidor no se pueden reproducir.
                if (row.getAttribute("data-available") !== "1") { button.disabled = true; }
                button.addEventListener("click", function () {
                    if (row.getAttribute("data-available") !== "1") { return; }
                    if (currentRow === row) { togglePlayPause(); } else { loadRow(row, true); }
                });
            });

            /* ---------- Filtro instantáneo (topbar + panel) ---------- */
            var searchTop = document.getElementById("searchInput");
            var searchInline = document.getElementById("searchInline");
            var noResults = document.getElementById("noResults");
            var btnClearSearch = document.getElementById("btnClearSearch");

            function applyFilter(term) {
                term = (term || "").toLowerCase().trim();
                var visible = 0;
                rows.forEach(function (row) {
                    var name = (row.getAttribute("data-name") || "").toLowerCase();
                    var match = term === "" || name.indexOf(term) >= 0;
                    row.style.display = match ? "" : "none";
                    if (match) { visible++; }
                });
                if (noResults) { noResults.hidden = !(visible === 0 && rows.length > 0); }
            }

            function syncSearch(source) {
                var value = source.value;
                if (searchTop && source !== searchTop) { searchTop.value = value; }
                if (searchInline && source !== searchInline) { searchInline.value = value; }
                applyFilter(value);
            }

            [searchTop, searchInline].forEach(function (input) {
                if (!input) { return; }
                input.addEventListener("input", function () { syncSearch(input); });
                input.addEventListener("keydown", function (event) {
                    // El filtro es instantáneo: Enter no debe enviar el formulario.
                    if (event.key === "Enter") { event.preventDefault(); }
                });
            });

            if (btnClearSearch) {
                btnClearSearch.addEventListener("click", function () {
                    if (searchTop) { searchTop.value = ""; }
                    if (searchInline) { searchInline.value = ""; }
                    applyFilter("");
                    focusSearch();
                });
            }

            // En pantallas pequeñas el buscador de la barra superior se oculta,
            // así que el atajo apunta al que esté visible.
            function focusSearch() {
                var target = (searchTop && searchTop.offsetParent !== null) ? searchTop : searchInline;
                if (target) { target.focus(); }
            }

            /* ---------- Modales ---------- */
            function closeModal(modal) {
                if (modal) { modal.classList.remove("is-open"); }
            }

            function findModal(node) {
                while (node && node !== document) {
                    if (node.classList && node.classList.contains("modal")) { return node; }
                    node = node.parentNode;
                }
                return null;
            }

            [].slice.call(document.querySelectorAll("[data-close]")).forEach(function (element) {
                element.addEventListener("click", function () { closeModal(findModal(element)); });
            });

            document.addEventListener("keydown", function (event) {
                var openModal = document.querySelector(".modal.is-open");
                if (event.key === "Escape" && openModal) {
                    closeModal(openModal);
                    return;
                }

                var tag = (event.target.tagName || "").toLowerCase();
                var typing = tag === "input" || tag === "textarea" || tag === "select" || tag === "button" || tag === "a";

                if (event.key === "/" && !typing) {
                    event.preventDefault();
                    focusSearch();
                }
                if (event.key === " " && !typing && !openModal) {
                    event.preventDefault();
                    togglePlayPause();
                }
            });

            /* ---------- Toasts ---------- */
            [].slice.call(document.querySelectorAll(".toast")).forEach(function (toast) {
                setTimeout(function () {
                    toast.style.transition = "opacity .35s ease, transform .35s ease";
                    toast.style.opacity = "0";
                    toast.style.transform = "translateX(18px)";
                    setTimeout(function () {
                        if (toast.parentNode) { toast.parentNode.removeChild(toast); }
                    }, 400);
                }, 4500);
            });

            /* ---------- Estado inicial ---------- */
            updatePlayIcon(false);
            audio.volume = 0.8;
        })();
    </script>
</body>
</html>

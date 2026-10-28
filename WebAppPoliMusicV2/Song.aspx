<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic · Canciones</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        /* ==================================================================
           PoliMusic · Song.aspx
           Design tokens + reset + layout + componentes
           ================================================================== */
        :root {
            --brand: #FF6A00;
            --brand-soft: #FF9A3C;
            --brand-deep: #D95500;
            --grad: linear-gradient(135deg, #FF9A3C 0%, #FF6A00 48%, #E23E00 100%);
            --grad-soft: linear-gradient(135deg, rgba(255, 154, 60, .18), rgba(226, 62, 0, .08));

            --bg: #0A0807;
            --text: #FAF5F0;
            --muted: #A2968D;
            --muted-2: #7A6E66;

            --glass: linear-gradient(160deg, rgba(255, 255, 255, .075), rgba(255, 255, 255, .022));
            --glass-strong: linear-gradient(160deg, rgba(255, 255, 255, .11), rgba(255, 255, 255, .035));
            --line: rgba(255, 255, 255, .085);
            --line-strong: rgba(255, 255, 255, .16);

            --ok: #3DDC97;
            --danger: #FF6B6B;

            --r-sm: 12px;
            --r-md: 18px;
            --r-lg: 26px;
            --r-xl: 34px;

            --shadow-glass: 0 26px 70px -34px rgba(0, 0, 0, .95), inset 0 1px 0 rgba(255, 255, 255, .09);
            --glow: 0 18px 44px -18px rgba(255, 106, 0, .6);

            --sidebar-w: 262px;
            --player-h: 92px;

            --ease-out: cubic-bezier(.22, 1, .36, 1);
            --ease-spring: cubic-bezier(.34, 1.32, .64, 1);
        }

        *, *::before, *::after { box-sizing: border-box; }

        html, body { height: 100%; }

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

        /* Fondo con manchas de color: le da materia al glassmorphism */
        .blobs { position: fixed; inset: 0; overflow: hidden; pointer-events: none; z-index: 0; }
        .blobs span {
            position: absolute;
            display: block;
            border-radius: 50%;
            filter: blur(90px);
            opacity: .55;
        }
        .blobs .b1 { width: 620px; height: 620px; top: -220px; left: -140px; background: radial-gradient(circle, rgba(255, 106, 0, .55), transparent 68%); animation: float1 18s ease-in-out infinite; }
        .blobs .b2 { width: 540px; height: 540px; top: -120px; right: -120px; background: radial-gradient(circle, rgba(226, 62, 0, .42), transparent 68%); animation: float2 22s ease-in-out infinite; }
        .blobs .b3 { width: 720px; height: 720px; bottom: -340px; left: 32%; background: radial-gradient(circle, rgba(255, 154, 60, .26), transparent 70%); animation: float1 26s ease-in-out infinite reverse; }

        @keyframes float1 { 0%, 100% { transform: translate3d(0, 0, 0) scale(1); } 50% { transform: translate3d(40px, 30px, 0) scale(1.08); } }
        @keyframes float2 { 0%, 100% { transform: translate3d(0, 0, 0) scale(1); } 50% { transform: translate3d(-46px, 26px, 0) scale(1.06); } }

        h1, h2, h3, h4 { font-family: "Outfit", sans-serif; margin: 0; letter-spacing: -.02em; font-weight: 600; }
        p { margin: 0; }
        a { color: inherit; text-decoration: none; }
        button { font-family: inherit; font-size: inherit; color: inherit; background: none; border: 0; cursor: pointer; }
        svg { width: 20px; height: 20px; display: block; }
        ::selection { background: rgba(255, 106, 0, .35); color: #fff; }

        :focus-visible { outline: 2px solid var(--brand-soft); outline-offset: 2px; border-radius: 6px; }

        .sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0 0 0 0); white-space: nowrap; border: 0; }

        /* ==================================================================
           LAYOUT
           ================================================================== */
        .app {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: var(--sidebar-w) minmax(0, 1fr);
            min-height: 100vh;
        }

        /* ---------- SIDEBAR ---------- */
        .sidebar {
            position: sticky;
            top: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            gap: 26px;
            padding: 24px 16px calc(var(--player-h) + 16px);
            background: linear-gradient(180deg, rgba(26, 18, 14, .72), rgba(10, 8, 7, .88));
            backdrop-filter: blur(26px) saturate(150%);
            -webkit-backdrop-filter: blur(26px) saturate(150%);
            border-right: 1px solid var(--line);
        }

        .brand { display: flex; align-items: center; gap: 12px; padding: 2px 8px; }
        .brand-mark {
            width: 42px; height: 42px; border-radius: 14px;
            display: grid; place-items: center; flex: none;
            background: var(--grad); color: #fff;
            box-shadow: var(--glow), inset 0 1px 0 rgba(255, 255, 255, .35);
        }
        .brand-mark svg { width: 22px; height: 22px; }
        .brand-text { display: flex; flex-direction: column; line-height: 1.15; }
        .brand-name { font-family: "Outfit", sans-serif; font-weight: 700; font-size: 17.5px; }
        .brand-sub { font-size: 10px; text-transform: uppercase; letter-spacing: .18em; color: var(--muted-2); font-weight: 600; }

        .nav-group { display: flex; flex-direction: column; gap: 3px; }
        .nav-label { font-size: 10px; text-transform: uppercase; letter-spacing: .18em; color: var(--muted-2); font-weight: 700; padding: 0 12px 8px; }
        .nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 12px; border-radius: 13px;
            color: var(--muted); font-weight: 500; font-size: 14px;
            position: relative;
            transition: background .2s var(--ease-out), color .2s var(--ease-out), transform .2s var(--ease-out);
        }
        .nav-item svg { width: 19px; height: 19px; flex: none; opacity: .9; }
        .nav-item:hover { background: rgba(255, 255, 255, .05); color: var(--text); transform: translateX(2px); }
        .nav-item.is-active {
            color: #fff;
            background: var(--grad-soft);
            border: 1px solid rgba(255, 106, 0, .28);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, .08);
        }
        .nav-item.is-active::before {
            content: ""; position: absolute; left: -16px; top: 50%; transform: translateY(-50%);
            width: 3px; height: 22px; border-radius: 0 3px 3px 0;
            background: var(--brand); box-shadow: 0 0 16px rgba(255, 106, 0, .85);
        }
        .nav-item.is-soon { opacity: .5; cursor: not-allowed; }
        .nav-tag {
            margin-left: auto; font-size: 9px; font-weight: 700; letter-spacing: .08em;
            text-transform: uppercase; color: var(--brand-soft);
            background: rgba(255, 106, 0, .14); padding: 2px 7px; border-radius: 99px;
        }

        .sidebar-foot { margin-top: auto; display: flex; flex-direction: column; gap: 12px; }
        .side-card {
            border: 1px solid var(--line); border-radius: var(--r-md); padding: 14px;
            background: var(--glass);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
        }
        .side-card h4 { font-size: 12.5px; margin-bottom: 5px; }
        .side-card p { font-size: 11.5px; color: var(--muted); line-height: 1.5; }
        .side-hint { display: flex; align-items: center; gap: 6px; margin-top: 10px; font-size: 11px; color: var(--brand-soft); font-weight: 600; }
        .side-hint svg { width: 14px; height: 14px; }

        kbd {
            font-family: inherit; font-size: 10.5px; font-weight: 700;
            background: rgba(255, 255, 255, .1); border: 1px solid var(--line-strong);
            border-bottom-width: 2px; border-radius: 6px; padding: 1px 6px; color: var(--text);
        }

        /* ---------- MAIN ---------- */
        .main { min-width: 0; padding: 0 0 calc(var(--player-h) + 34px); display: flex; flex-direction: column; }

        .topbar {
            position: sticky; top: 0; z-index: 40;
            display: flex; align-items: center; gap: 16px;
            padding: 14px 30px;
            background: rgba(10, 8, 7, .55);
            backdrop-filter: blur(24px) saturate(160%);
            -webkit-backdrop-filter: blur(24px) saturate(160%);
            border-bottom: 1px solid var(--line);
        }
        .crumbs { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: var(--muted-2); }
        .crumbs strong { color: var(--text); font-weight: 600; }
        .crumbs .sep { opacity: .45; }

        .topbar-right { margin-left: auto; display: flex; align-items: center; gap: 10px; }

        .user-chip {
            display: flex; align-items: center; gap: 10px;
            padding: 5px 14px 5px 5px; border-radius: 99px;
            background: rgba(255, 255, 255, .05);
            border: 1px solid var(--line);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            transition: border-color .2s, background .2s;
        }
        .user-chip:hover { border-color: rgba(255, 106, 0, .38); background: rgba(255, 106, 0, .07); }
        .avatar {
            width: 34px; height: 34px; border-radius: 50%; flex: none;
            display: grid; place-items: center; overflow: hidden;
            background: var(--grad); color: #fff;
            font-size: 12.5px; font-weight: 700;
            box-shadow: 0 0 0 2px rgba(255, 106, 0, .22);
        }
        .avatar img { width: 100%; height: 100%; object-fit: cover; }
        .user-meta { display: flex; flex-direction: column; line-height: 1.2; min-width: 0; }
        .user-name { font-size: 13px; font-weight: 600; max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .user-role { font-size: 10px; color: var(--brand-soft); font-weight: 700; letter-spacing: .06em; text-transform: uppercase; }

        /* ---------- BOTONES ---------- */
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            padding: 11px 18px; border-radius: 13px;
            font-weight: 600; font-size: 13.5px; line-height: 1;
            border: 1px solid transparent; white-space: nowrap;
            transition: transform .18s var(--ease-spring), background .2s, border-color .2s, box-shadow .25s, color .2s;
        }
        .btn:active { transform: scale(.97); }
        .btn svg { width: 17px; height: 17px; }
        .btn-primary { background: var(--grad); color: #fff; box-shadow: 0 10px 26px -12px rgba(255, 106, 0, .9), inset 0 1px 0 rgba(255, 255, 255, .3); }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 16px 34px -12px rgba(255, 106, 0, 1); }
        .btn-ghost { background: rgba(255, 255, 255, .05); color: var(--muted); border-color: var(--line); }
        .btn-ghost:hover { color: var(--text); background: rgba(255, 255, 255, .085); border-color: var(--line-strong); }
        .btn-danger { background: rgba(255, 107, 107, .14); color: #FF9B9B; border-color: rgba(255, 107, 107, .32); }
        .btn-danger:hover { background: rgba(255, 107, 107, .22); color: #FFC0C0; }

        .icon-btn {
            width: 36px; height: 36px; border-radius: 11px; padding: 0;
            display: inline-grid; place-items: center;
            background: rgba(255, 255, 255, .045);
            border: 1px solid var(--line);
            color: var(--muted);
            transition: color .18s, background .18s, border-color .18s, transform .18s var(--ease-spring);
        }
        .icon-btn svg { width: 17px; height: 17px; }
        .icon-btn:hover { color: var(--text); background: rgba(255, 255, 255, .09); border-color: var(--line-strong); transform: translateY(-1px); }
        .icon-btn.danger:hover { color: #FFB0B0; background: rgba(255, 107, 107, .16); border-color: rgba(255, 107, 107, .35); }
        .icon-btn.play { color: var(--brand-soft); background: rgba(255, 106, 0, .1); border-color: rgba(255, 106, 0, .24); }
        .icon-btn.play:hover { color: #fff; background: var(--grad); border-color: transparent; box-shadow: var(--glow); }
        .icon-btn[disabled] { opacity: .32; cursor: not-allowed; transform: none; }
        .icon-btn[disabled]:hover { color: var(--muted); background: rgba(255, 255, 255, .045); border-color: var(--line); box-shadow: none; }

        /* ---------- CONTENIDO ---------- */
        .content { padding: 26px 30px 10px; display: flex; flex-direction: column; gap: 20px; }

        .glass {
            background: var(--glass);
            backdrop-filter: blur(26px) saturate(160%);
            -webkit-backdrop-filter: blur(26px) saturate(160%);
            border: 1px solid var(--line);
            box-shadow: var(--shadow-glass);
        }

        /* ---------- HERO ---------- */
        .hero {
            position: relative;
            display: flex; align-items: center; gap: 24px;
            padding: 30px 32px;
            border-radius: var(--r-xl);
            overflow: hidden;
        }
        .hero::after {
            content: ""; position: absolute; inset: 0; pointer-events: none;
            background: radial-gradient(600px 240px at 88% 0%, rgba(255, 106, 0, .22), transparent 70%);
        }
        .hero-copy { position: relative; z-index: 1; display: flex; flex-direction: column; gap: 10px; }
        .eyebrow {
            display: inline-flex; align-items: center; gap: 8px;
            font-size: 10.5px; font-weight: 700; letter-spacing: .18em; text-transform: uppercase;
            color: var(--brand-soft);
        }
        .eyebrow .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--brand); box-shadow: 0 0 12px rgba(255, 106, 0, .9); }
        .hero h1 { font-size: 42px; font-weight: 700; letter-spacing: -.035em; line-height: 1.05; }
        .hero h1 em {
            font-style: normal;
            background: var(--grad);
            -webkit-background-clip: text; background-clip: text;
            -webkit-text-fill-color: transparent; color: transparent;
        }
        .hero-sub { font-size: 13.5px; color: var(--muted); max-width: 560px; line-height: 1.6; }
        .hero-sub strong { color: var(--text); font-weight: 600; }
        .hero-actions { display: flex; align-items: center; gap: 10px; margin-top: 6px; flex-wrap: wrap; }

        .hero-art { position: relative; z-index: 1; margin-left: auto; width: 150px; height: 150px; flex: none; display: grid; place-items: center; }
        .hero-art .ring { position: absolute; border-radius: 50%; border: 1px solid rgba(255, 106, 0, .28); }
        .hero-art .r1 { inset: 0; animation: spin 26s linear infinite; }
        .hero-art .r2 { inset: 20px; border-color: rgba(255, 154, 60, .22); }
        .hero-art .r3 { inset: 40px; border-color: rgba(255, 255, 255, .1); }
        .hero-art .r1::after {
            content: ""; position: absolute; top: -3px; left: 50%; width: 6px; height: 6px;
            border-radius: 50%; background: var(--brand-soft); box-shadow: 0 0 14px rgba(255, 154, 60, 1);
        }
        .hero-note {
            width: 54px; height: 54px; border-radius: 18px;
            display: grid; place-items: center;
            background: var(--grad); color: #fff;
            box-shadow: var(--glow), inset 0 1px 0 rgba(255, 255, 255, .35);
            font-size: 24px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* ---------- STATS ---------- */
        .stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; }
        .stat {
            padding: 16px 18px; border-radius: var(--r-md);
            display: flex; flex-direction: column; gap: 8px;
            transition: transform .25s var(--ease-out), border-color .25s;
        }
        .stat:hover { transform: translateY(-2px); border-color: rgba(255, 106, 0, .3); }
        .stat-top { display: flex; align-items: center; gap: 8px; font-size: 11px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .1em; }
        .stat-top svg { width: 15px; height: 15px; color: var(--brand-soft); }
        .stat-value { font-family: "Outfit", sans-serif; font-size: 27px; font-weight: 700; letter-spacing: -.03em; line-height: 1; }

        /* ---------- CARD / LISTA ---------- */
        .card { border-radius: var(--r-lg); padding: 22px 24px 24px; display: flex; flex-direction: column; gap: 16px; }
        .card-head { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
        .card-title-wrap { display: flex; align-items: center; gap: 10px; }
        .card-title-wrap h2 { font-size: 18px; }
        .count-chip {
            font-size: 10.5px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase;
            color: var(--brand-soft); background: rgba(255, 106, 0, .13);
            border: 1px solid rgba(255, 106, 0, .22);
            padding: 3px 10px; border-radius: 99px;
        }

        .search { position: relative; display: flex; align-items: center; margin-left: auto; }
        .search svg { position: absolute; left: 13px; width: 16px; height: 16px; color: var(--muted-2); pointer-events: none; }
        .search input {
            width: 280px; max-width: 100%;
            padding: 10px 44px 10px 38px;
            border-radius: 12px;
            background: rgba(255, 255, 255, .05);
            border: 1px solid var(--line);
            color: var(--text); font-size: 13px; font-family: inherit;
            transition: border-color .2s, box-shadow .2s, background .2s;
        }
        .search input::placeholder { color: var(--muted-2); }
        .search input:focus { outline: none; border-color: rgba(255, 106, 0, .6); background: rgba(255, 106, 0, .06); box-shadow: 0 0 0 3px rgba(255, 106, 0, .14); }
        .search kbd { position: absolute; right: 10px; pointer-events: none; }

        .song-list { display: flex; flex-direction: column; }

        .song-head, .song-row {
            display: grid;
            grid-template-columns: 44px minmax(0, 1fr) 128px 194px;
            align-items: center;
            gap: 14px;
        }
        .song-head {
            padding: 0 12px 10px;
            font-size: 10.5px; text-transform: uppercase; letter-spacing: .14em;
            font-weight: 700; color: var(--muted-2);
            border-bottom: 1px solid var(--line);
        }
        .song-head .col-actions { text-align: right; }

        .song-row {
            position: relative;
            padding: 9px 12px;
            border-radius: 14px;
            border: 1px solid transparent;
            transition: background .2s var(--ease-out), border-color .2s, transform .2s var(--ease-out);
        }
        .song-row + .song-row { margin-top: 2px; }
        .song-row:hover { background: rgba(255, 255, 255, .055); border-color: var(--line); }
        .song-row.is-playing { background: var(--grad-soft); border-color: rgba(255, 106, 0, .3); }
        .song-row.is-playing .song-name { color: #fff; }

        .row-index { font-size: 12px; color: var(--muted-2); font-variant-numeric: tabular-nums; text-align: center; }

        .song-main { display: flex; align-items: center; gap: 13px; min-width: 0; }

        .cover {
            position: relative; flex: none;
            width: 46px; height: 46px; border-radius: 12px;
            display: grid; place-items: center;
            font-family: "Outfit", sans-serif; font-weight: 700; font-size: 17px; color: #fff;
            background: linear-gradient(135deg, #FF9A3C, #E23E00);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, .28), 0 8px 18px -12px rgba(0, 0, 0, .9);
            overflow: hidden;
        }
        .cover img { width: 100%; height: 100%; object-fit: cover; }

        /* Variación de portadas: la paleta naranja se reparte entre las filas */
        .song-row:nth-child(6n+2) .cover { background: linear-gradient(135deg, #FFB020, #D95500); }
        .song-row:nth-child(6n+3) .cover { background: linear-gradient(135deg, #FF7A45, #B23A48); }
        .song-row:nth-child(6n+4) .cover { background: linear-gradient(135deg, #F48C06, #7A2E0E); }
        .song-row:nth-child(6n+5) .cover { background: linear-gradient(135deg, #FFC24B, #E8590C); }
        .song-row:nth-child(6n+6) .cover { background: linear-gradient(135deg, #FF9A3C, #A33B00); }

        .eq { display: none; position: absolute; inset: 0; align-items: flex-end; justify-content: center; gap: 2px; padding-bottom: 12px; background: rgba(10, 8, 7, .55); }
        .song-row.is-playing .eq { display: flex; }
        .eq i { display: block; width: 2.5px; height: 10px; border-radius: 2px; background: #fff; animation: eq 1s ease-in-out infinite; }
        .eq i:nth-child(2) { animation-delay: .18s; }
        .eq i:nth-child(3) { animation-delay: .36s; }
        @keyframes eq { 0%, 100% { height: 4px; } 50% { height: 13px; } }

        .song-text { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .song-name { font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: flex; align-items: center; gap: 8px; }
        .song-sub { font-size: 11.5px; color: var(--muted-2); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .flag {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 9.5px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase;
            color: #FFC24B; background: rgba(255, 194, 75, .13);
            border: 1px solid rgba(255, 194, 75, .28);
            padding: 1px 7px; border-radius: 99px; flex: none;
        }
        .flag svg { width: 11px; height: 11px; }

        .col-plays { font-size: 12.5px; color: var(--muted); font-variant-numeric: tabular-nums; text-align: right; padding-right: 8px; }
        .song-head .col-plays { font-size: 10.5px; font-weight: 700; color: var(--muted-2); }
        .row-actions { display: flex; align-items: center; justify-content: flex-end; gap: 6px; }

        .link-action {
            font-size: 10.5px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase;
            color: var(--muted-2); text-decoration: none; white-space: nowrap;
            padding: 7px 10px; border-radius: 10px; border: 1px solid transparent;
            transition: color .18s, background .18s, border-color .18s;
        }
        .link-action:hover { color: var(--brand-soft); background: rgba(255, 106, 0, .11); border-color: rgba(255, 106, 0, .26); }
        .link-action.danger:hover { color: #FFB0B0; background: rgba(255, 107, 107, .14); border-color: rgba(255, 107, 107, .3); }

        /* ---------- ESTADO VACÍO ---------- */
        .empty { display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 54px 20px; text-align: center; }
        .empty[hidden] { display: none; }
        .empty-icon {
            width: 58px; height: 58px; border-radius: 18px; display: grid; place-items: center;
            background: rgba(255, 106, 0, .12); border: 1px solid rgba(255, 106, 0, .24); color: var(--brand-soft);
            margin-bottom: 4px;
        }
        .empty-icon svg { width: 26px; height: 26px; }
        .empty h3 { font-size: 17px; }
        .empty p { font-size: 13px; color: var(--muted); max-width: 380px; line-height: 1.6; }
        .empty .btn { margin-top: 10px; }

        .foot { display: flex; align-items: center; gap: 10px; font-size: 11.5px; color: var(--muted-2); padding: 0 4px 8px; flex-wrap: wrap; }
        .foot .sep { width: 3px; height: 3px; border-radius: 50%; background: currentColor; opacity: .5; }

        /* ==================================================================
           REPRODUCTOR
           ================================================================== */
        .player {
            position: fixed; left: 0; right: 0; bottom: 0; z-index: 60;
            height: var(--player-h);
            display: grid;
            grid-template-columns: minmax(180px, 1fr) minmax(320px, 2fr) minmax(140px, 1fr);
            align-items: center; gap: 20px;
            padding: 0 24px;
            background: rgba(14, 10, 8, .72);
            backdrop-filter: blur(28px) saturate(170%);
            -webkit-backdrop-filter: blur(28px) saturate(170%);
            border-top: 1px solid var(--line-strong);
            box-shadow: 0 -24px 60px -34px rgba(0, 0, 0, 1);
        }
        .player::before {
            content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 106, 0, .6), transparent);
        }
        .player-track { display: flex; align-items: center; gap: 12px; min-width: 0; }
        .player .cover { width: 52px; height: 52px; border-radius: 13px; font-size: 18px; }
        .player-meta { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .player-title { font-size: 13.5px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .player-artist { font-size: 11.5px; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .player-center { display: flex; flex-direction: column; align-items: center; gap: 8px; }
        .player-controls { display: flex; align-items: center; gap: 14px; }
        .pc-btn {
            width: 34px; height: 34px; border-radius: 50%;
            display: grid; place-items: center; color: var(--muted);
            transition: color .18s, transform .18s var(--ease-spring), background .18s;
        }
        .pc-btn svg { width: 17px; height: 17px; }
        .pc-btn:hover { color: var(--text); background: rgba(255, 255, 255, .07); }
        .pc-btn:active { transform: scale(.92); }
        .pc-btn.primary {
            width: 44px; height: 44px; color: #fff; background: var(--grad);
            box-shadow: 0 10px 26px -12px rgba(255, 106, 0, 1), inset 0 1px 0 rgba(255, 255, 255, .3);
        }
        .pc-btn.primary svg { width: 19px; height: 19px; }
        .pc-btn.primary:hover { transform: scale(1.06); color: #fff; }
        .pc-btn[disabled] { opacity: .35; cursor: not-allowed; }

        .timeline { display: flex; align-items: center; gap: 10px; width: 100%; max-width: 540px; }
        .timeline span { font-size: 10.5px; color: var(--muted-2); font-variant-numeric: tabular-nums; min-width: 34px; text-align: center; }

        input[type=range] {
            -webkit-appearance: none; appearance: none;
            width: 100%; height: 4px; border-radius: 99px; outline: none; cursor: pointer;
            background: linear-gradient(to right, var(--brand) 0%, var(--brand) calc(var(--p, 0) * 1%), rgba(255, 255, 255, .16) calc(var(--p, 0) * 1%), rgba(255, 255, 255, .16) 100%);
        }
        input[type=range]::-webkit-slider-thumb {
            -webkit-appearance: none; appearance: none;
            width: 12px; height: 12px; border-radius: 50%; background: #fff;
            box-shadow: 0 0 0 4px rgba(255, 106, 0, .22), 0 2px 6px rgba(0, 0, 0, .5);
            transition: transform .15s;
        }
        input[type=range]:hover::-webkit-slider-thumb { transform: scale(1.15); }
        input[type=range]::-moz-range-thumb { width: 12px; height: 12px; border: 0; border-radius: 50%; background: #fff; box-shadow: 0 0 0 4px rgba(255, 106, 0, .22); }

        .player-right { display: flex; align-items: center; gap: 10px; justify-content: flex-end; }
        .player-right input[type=range] { max-width: 96px; }

        /* ==================================================================
           MODALES
           ================================================================== */
        .modal { position: fixed; inset: 0; z-index: 100; display: none; align-items: center; justify-content: center; padding: 20px; }
        .modal.is-open { display: flex; }
        .modal-backdrop { position: absolute; inset: 0; background: rgba(6, 4, 3, .68); backdrop-filter: blur(7px); -webkit-backdrop-filter: blur(7px); }
        .modal-card {
            position: relative;
            width: 100%; max-width: 520px; max-height: calc(100vh - 40px); overflow-y: auto;
            padding: 24px; border-radius: var(--r-lg);
            background: linear-gradient(170deg, rgba(38, 27, 21, .96), rgba(16, 12, 10, .98));
            border: 1px solid var(--line-strong);
            box-shadow: 0 44px 100px -34px rgba(0, 0, 0, 1), inset 0 1px 0 rgba(255, 255, 255, .1);
            animation: pop .28s var(--ease-spring);
        }
        @keyframes pop { from { opacity: 0; transform: translateY(14px) scale(.97); } to { opacity: 1; transform: none; } }

        .modal-head { display: flex; align-items: flex-start; gap: 14px; margin-bottom: 20px; }
        .modal-head h3 { font-size: 18px; }
        .modal-head p { font-size: 12.5px; color: var(--muted); margin-top: 4px; line-height: 1.5; }
        .modal-head .icon-btn { margin-left: auto; flex: none; }
        .modal-icon {
            width: 42px; height: 42px; border-radius: 14px; flex: none;
            display: grid; place-items: center;
            background: rgba(255, 106, 0, .13); border: 1px solid rgba(255, 106, 0, .26); color: var(--brand-soft);
        }
        .modal-icon.danger { background: rgba(255, 107, 107, .13); border-color: rgba(255, 107, 107, .3); color: #FF9B9B; }
        .modal-icon svg { width: 20px; height: 20px; }

        .field { margin-bottom: 16px; }
        .field label { display: flex; align-items: center; justify-content: space-between; gap: 8px; font-size: 12px; font-weight: 600; color: var(--muted); margin-bottom: 7px; }
        .field label .req { color: var(--brand-soft); }
        .field .hint { font-size: 10.5px; color: var(--muted-2); font-weight: 500; }
        .field input[type=text], .field input[type=file] {
            width: 100%; padding: 11px 14px; border-radius: 12px;
            background: rgba(255, 255, 255, .045);
            border: 1px solid var(--line);
            color: var(--text); font-size: 13.5px; font-family: inherit;
            transition: border-color .2s, box-shadow .2s, background .2s;
        }
        .field input::placeholder { color: var(--muted-2); }
        .field input[type=text]:focus { outline: none; border-color: rgba(255, 106, 0, .6); background: rgba(255, 106, 0, .06); box-shadow: 0 0 0 3px rgba(255, 106, 0, .14); }
        .field input[type=file] { padding: 9px 12px; color: var(--muted); font-size: 12.5px; }
        .field input[type=file]::file-selector-button {
            margin-right: 12px; padding: 7px 12px; border-radius: 9px; border: 1px solid var(--line-strong);
            background: rgba(255, 255, 255, .07); color: var(--text); font-family: inherit; font-size: 12px; font-weight: 600; cursor: pointer;
        }
        .field-note { font-size: 11px; color: var(--muted-2); margin-top: 6px; line-height: 1.5; }

        .form-alert {
            display: flex; gap: 10px; align-items: flex-start;
            padding: 12px 14px; border-radius: 12px; margin-bottom: 16px;
            background: rgba(255, 107, 107, .1); border: 1px solid rgba(255, 107, 107, .3);
            font-size: 12.5px; color: #FFB3B3; line-height: 1.5;
        }
        .form-alert svg { width: 16px; height: 16px; flex: none; margin-top: 1px; color: #FF9B9B; }

        .modal-foot { display: flex; gap: 10px; justify-content: flex-end; margin-top: 22px; flex-wrap: wrap; }
        .modal-foot .btn { min-width: 108px; }
        .modal-foot .btn[type=submit] { -webkit-appearance: none; }

        /* ==================================================================
           TOASTS
           ================================================================== */
        .toasts { position: fixed; right: 22px; bottom: calc(var(--player-h) + 18px); z-index: 120; display: flex; flex-direction: column; gap: 10px; pointer-events: none; }
        .toast {
            display: flex; align-items: flex-start; gap: 11px;
            min-width: 260px; max-width: 380px; padding: 13px 15px;
            border-radius: 14px;
            background: rgba(32, 24, 19, .95);
            border: 1px solid var(--line-strong);
            box-shadow: 0 22px 48px -22px rgba(0, 0, 0, 1);
            backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
            pointer-events: auto;
            animation: toastIn .3s var(--ease-spring);
        }
        @keyframes toastIn { from { opacity: 0; transform: translateX(18px); } to { opacity: 1; transform: none; } }
        .toast .t-icon { width: 26px; height: 26px; border-radius: 9px; flex: none; display: grid; place-items: center; }
        .toast .t-icon svg { width: 14px; height: 14px; }
        .toast.success .t-icon { background: rgba(61, 220, 151, .15); color: var(--ok); }
        .toast.error .t-icon { background: rgba(255, 107, 107, .15); color: #FF9B9B; }
        .toast.info .t-icon { background: rgba(255, 106, 0, .15); color: var(--brand-soft); }
        .toast .t-body { display: flex; flex-direction: column; gap: 1px; min-width: 0; }
        .toast .t-title { font-size: 12.5px; font-weight: 600; }
        .toast .t-msg { font-size: 12px; color: var(--muted); line-height: 1.45; }

        /* ==================================================================
           RESPONSIVE
           ================================================================== */
        @media (max-width: 1180px) {
            .hero h1 { font-size: 36px; }
            .hero-art { width: 120px; height: 120px; }
        }
        @media (max-width: 1024px) {
            .app { grid-template-columns: minmax(0, 1fr); }
            .sidebar { display: none; }
            .content { padding: 20px 18px 10px; }
            .topbar { padding: 12px 18px; }
            .stats { grid-template-columns: repeat(3, minmax(0, 1fr)); }
            .song-head, .song-row { grid-template-columns: 36px minmax(0, 1fr) 84px 178px; }
            .search input { width: 210px; }
        }
        @media (max-width: 760px) {
            .hero { flex-direction: column; align-items: flex-start; padding: 24px; }
            .hero-art { display: none; }
            .hero h1 { font-size: 30px; }
            .stats { grid-template-columns: 1fr; }
            .card { padding: 18px 14px; }
            .song-head { display: none; }
            .song-row { grid-template-columns: 34px minmax(0, 1fr) 168px; }
            .song-row .col-plays { display: none; }
            .search { margin-left: 0; width: 100%; }
            .search input { width: 100%; }
            .user-meta { display: none; }
            .player { grid-template-columns: 1fr auto; padding: 0 14px; gap: 10px; }
            .player-center .timeline { display: none; }
            .player-right { display: none; }
            .foot { display: none; }
        }
    </style>
</head>
<body>
    <div class="blobs" aria-hidden="true"><span class="b1"></span><span class="b2"></span><span class="b3"></span></div>

    <form id="form1" runat="server">
        <div class="app">

            <!-- ==================== SIDEBAR ==================== -->
            <aside class="sidebar">
                <a class="brand" href="Default.aspx">
                    <span class="brand-mark">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                    </span>
                    <span class="brand-text">
                        <span class="brand-name">PoliMusic</span>
                        <span class="brand-sub">Music App</span>
                    </span>
                </a>

                <nav class="nav-group" aria-label="Navegación principal">
                    <span class="nav-label">Descubrir</span>
                    <a class="nav-item" href="Default.aspx">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V21h14V9.5" /></svg>
                        <span>Inicio</span>
                    </a>
                    <a class="nav-item is-active" href="Song.aspx" aria-current="page">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13" /><path d="M8 12h13" /><path d="M8 18h13" /><path d="M3 6h.01" /><path d="M3 12h.01" /><path d="M3 18h.01" /></svg>
                        <span>Canciones</span>
                    </a>
                    <span class="nav-item is-soon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></svg>
                        <span>Playlists</span><span class="nav-tag">Pronto</span>
                    </span>
                    <span class="nav-item is-soon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15a4 4 0 0 0 4-4V6a4 4 0 0 0-8 0v5a4 4 0 0 0 4 4Z" /><path d="M19 11a7 7 0 0 1-14 0" /><path d="M12 18v3" /></svg>
                        <span>Artistas</span><span class="nav-tag">Pronto</span>
                    </span>
                </nav>

                <div class="sidebar-foot">
                    <div class="side-card">
                        <h4>Atajos rápidos</h4>
                        <p>Busca con <kbd>/</kbd> y reproduce o pausa con <kbd>espacio</kbd>.</p>
                        <span class="side-hint">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9" /><path d="M12 8v4l3 2" /></svg>
                            Reproducción continua
                        </span>
                    </div>
                </div>
            </aside>

            <!-- ==================== MAIN ==================== -->
            <div class="main">
                <header class="topbar">
                    <div class="crumbs">
                        <span>Biblioteca</span>
                        <span class="sep">/</span>
                        <strong>Canciones</strong>
                    </div>

                    <div class="topbar-right">
                        <div class="user-chip" title="Sesión iniciada">
                            <span class="avatar"><asp:Literal ID="litAvatar" runat="server" /></span>
                            <span class="user-meta">
                                <span class="user-name"><asp:Literal ID="litUserName" runat="server" /></span>
                                <span class="user-role"><asp:Literal ID="litUserRole" runat="server" /></span>
                            </span>
                        </div>
                        <asp:HyperLink ID="lnkLogout" runat="server" CssClass="btn btn-ghost" NavigateUrl="~/Logout.aspx" Text="Cerrar sesión" />
                    </div>
                </header>

                <main id="contenido" class="content">

                    <!-- HERO -->
                    <section class="hero glass">
                        <div class="hero-copy">
                            <span class="eyebrow"><span class="dot"></span>Tu biblioteca</span>
                            <h1>Song <em>List</em></h1>
                            <p class="hero-sub">
                                Hola <strong><asp:Literal ID="litHeroName" runat="server" /></strong>, este es el catálogo completo de
                                <strong>PoliMusic</strong>. Elige una canción de la lista y empieza a reproducirla.
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
                            <span class="ring r1"></span>
                            <span class="ring r2"></span>
                            <span class="ring r3"></span>
                            <span class="hero-note">&#9834;</span>
                        </div>
                    </section>

                    <!-- STATS -->
                    <section class="stats" aria-label="Resumen del catálogo">
                        <article class="stat glass">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13" /><path d="M8 12h13" /><path d="M8 18h13" /><path d="M3 6h.01" /><path d="M3 12h.01" /><path d="M3 18h.01" /></svg>
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
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                                <span>Con audio</span>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatAudio" runat="server" /></div>
                        </article>
                    </section>

                    <!-- LISTA -->
                    <section class="card glass">
                        <div class="card-head">
                            <div class="card-title-wrap">
                                <h2>Canciones</h2>
                                <span class="count-chip"><asp:Literal ID="litCountChip" runat="server" /></span>
                            </div>
                            <div class="search">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                                <input type="search" id="searchInput" placeholder="Buscar canción…" aria-label="Buscar canciones" autocomplete="off" />
                                <kbd>/</kbd>
                            </div>
                        </div>

                        <div class="song-list">
                            <div class="song-head" aria-hidden="true">
                                <span>#</span>
                                <span>Canción</span>
                                <span class="col-plays">Reproducciones</span>
                                <span class="col-actions">Acciones</span>
                            </div>

                            <asp:Repeater ID="rptSongs" runat="server" OnItemCommand="rptSongs_ItemCommand">
                                <ItemTemplate>
                                    <div class="song-row"
                                        data-id='<%# AttrEncode(Eval("ID_SONG")) %>'
                                        data-name='<%# AttrEncode(Eval("SONG_NAME")) %>'
                                        data-src='<%# AttrEncode(SongUrl(Eval("SONG_PATH"))) %>'
                                        data-available='<%# IsAvailable(Eval("SONG_PATH")) %>'
                                        data-plays='<%# AttrEncode(Eval("PLAYS")) %>'>
                                        <span class="row-index"><%# RowNumber(Container.ItemIndex) %></span>

                                        <div class="song-main">
                                            <div class="cover" aria-hidden="true">
                                                <span><%# SongInitial(Eval("SONG_NAME")) %></span>
                                                <span class="eq"><i></i><i></i><i></i></span>
                                            </div>
                                            <div class="song-text">
                                                <span class="song-name">
                                                    <%# HtmlText(Eval("SONG_NAME")) %>
                                                    <%# MissingFlag(Eval("SONG_PATH")) %>
                                                </span>
                                                <span class="song-sub"><%# FileName(Eval("SONG_PATH")) %></span>
                                            </div>
                                        </div>

                                        <span class="col-plays" data-plays-cell><%# PlaysText(Eval("PLAYS")) %></span>

                                        <div class="row-actions">
                                            <button type="button" class="icon-btn play" data-play title="Reproducir" aria-label="Reproducir"<%# PlayDisabled(Eval("SONG_PATH")) %>>
                                                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                                            </button>
                                            <asp:LinkButton ID="lnkEdit" runat="server" CssClass="link-action" CommandName="edit" CommandArgument='<%# Eval("ID_SONG") %>' Text="Editar" />
                                            <asp:LinkButton ID="lnkDelete" runat="server" CssClass="link-action danger" CommandName="delete" CommandArgument='<%# Eval("ID_SONG") %>' Text="Eliminar" />
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
                                <button type="button" class="btn btn-ghost" id="btnClearSearch">Limpiar búsqueda</button>
                            </div>
                        </div>
                    </section>

                    <div class="foot">
                        <span>PoliMusic</span>
                        <span class="sep"></span>
                        <span>ASP.NET WebForms + SQL Server</span>
                        <span class="sep"></span>
                        <span>Catálogo TBL_SONG</span>
                    </div>
                </main>
            </div>
        </div>

        <!-- ==================== REPRODUCTOR ==================== -->
        <div class="player" role="region" aria-label="Reproductor de audio">
            <div class="player-track">
                <div class="cover" id="playerCover" aria-hidden="true"><span id="playerCoverText">&#9834;</span></div>
                <div class="player-meta">
                    <span class="player-title" id="playerTitle">Ninguna canción seleccionada</span>
                    <span class="player-artist" id="playerArtist">Elige una canción de la lista</span>
                </div>
            </div>

            <div class="player-center">
                <div class="player-controls">
                    <button type="button" class="pc-btn" id="btnPrev" title="Anterior" aria-label="Canción anterior">
                        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 5h2v14H6z" /><path d="M20 5.6v12.8a1 1 0 0 1-1.55.83l-9-6.4a1 1 0 0 1 0-1.66l9-6.4A1 1 0 0 1 20 5.6Z" /></svg>
                    </button>
                    <button type="button" class="pc-btn primary" id="btnPlayPause" title="Reproducir / Pausar" aria-label="Reproducir">
                        <svg viewBox="0 0 24 24" fill="currentColor" id="icoPlay"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                    </button>
                    <button type="button" class="pc-btn" id="btnNext" title="Siguiente" aria-label="Siguiente canción">
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
                <button type="button" class="pc-btn" id="btnMute" title="Silenciar" aria-label="Silenciar">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H3v6h3l5 4V5Z" /><path d="M16 9a4 4 0 0 1 0 6" /><path d="M19 6a8 8 0 0 1 0 12" /></svg>
                </button>
                <input type="range" id="volume" min="0" max="1" step="0.01" value="0.8" aria-label="Volumen" style="--p: 80" />
            </div>

            <audio id="pmAudio" preload="metadata"></audio>
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
                    <p class="field-note">Usa una ruta lógica, por ejemplo <code>~/songFiles/mi-cancion.mp3</code>.</p>
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
            <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="deleteTitle" style="max-width: 440px;">
                <div class="modal-head">
                    <span class="modal-icon danger">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18" /><path d="M8 6V4h8v2" /><path d="M19 6l-1 14H6L5 6" /><path d="M10 11v5" /><path d="M14 11v5" /></svg>
                    </span>
                    <div>
                        <h3 id="deleteTitle">Eliminar canción</h3>
                        <p>Esta acción no se puede deshacer. La canción se quitará también de las playlists y álbumes donde aparezca.</p>
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

    <script type="text/javascript">
        (function () {
            "use strict";

            var audio = document.getElementById("pmAudio");
            if (!audio) { return; }

            var ICON_PLAY = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z"/></svg>';
            var ICON_PAUSE = '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="7" y="5" width="3.6" height="14" rx="1.2"/><rect x="13.4" y="5" width="3.6" height="14" rx="1.2"/></svg>';

            var rows = [].slice.call(document.querySelectorAll(".song-row"));
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
            var playerArtist = document.getElementById("playerArtist");
            var playerCover = document.getElementById("playerCover");
            var playerCoverText = document.getElementById("playerCoverText");

            var COVERS = [
                "linear-gradient(135deg,#FF9A3C,#E23E00)",
                "linear-gradient(135deg,#FFB020,#D95500)",
                "linear-gradient(135deg,#FF7A45,#B23A48)",
                "linear-gradient(135deg,#F48C06,#7A2E0E)",
                "linear-gradient(135deg,#FFC24B,#E8590C)",
                "linear-gradient(135deg,#FF9A3C,#A33B00)"
            ];

            var currentRow = null;
            var countedId = null;

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { return "0:00"; }
                var total = Math.floor(seconds);
                var minutes = Math.floor(total / 60);
                var rest = total % 60;
                return minutes + ":" + (rest < 10 ? "0" + rest : rest);
            }

            function setRangeFill(element, percent) {
                element.style.setProperty("--p", percent);
            }

            function highlightRow(row) {
                rows.forEach(function (item) { item.classList.remove("is-playing"); });
                if (row) { row.classList.add("is-playing"); }
            }

            function updatePlayIcon(playing) {
                btnPlayPause.innerHTML = playing ? ICON_PAUSE : ICON_PLAY;
                btnPlayPause.setAttribute("aria-label", playing ? "Pausar" : "Reproducir");
            }

            function updatePlays(row, value) {
                if (!row) { return; }
                row.setAttribute("data-plays", value);
                var cell = row.querySelector("[data-plays-cell]");
                if (cell) { cell.textContent = value; }
            }

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
                                updatePlays(row, data.plays);
                                var stat = document.getElementById("statPlays");
                                if (stat) {
                                    stat.textContent = parseInt(stat.textContent, 10) + 1 || 1;
                                }
                            }
                        } catch (error) { /* respuesta no JSON: se ignora */ }
                    };
                    xhr.send();
                } catch (error) { /* sin conexión: no se bloquea la reproducción */ }
            }

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

                playerTitle.textContent = row.getAttribute("data-name");
                playerArtist.textContent = "PoliMusic";
                playerCover.style.background = COVERS[(parseInt(row.getAttribute("data-id"), 10) || 0) % COVERS.length];
                playerCoverText.textContent = (row.getAttribute("data-name") || "♪").charAt(0).toUpperCase();

                audio.src = src;
                seek.value = 0;
                setRangeFill(seek, 0);
                timeCurrent.textContent = "0:00";

                if (autoplay) { startAudio(row); }
            }

            function playableIndex(row) { return playable.indexOf(row); }

            function step(offset) {
                if (playable.length === 0) { return; }
                var index = currentRow ? playableIndex(currentRow) : -1;
                if (index < 0) { index = 0; } else {
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
                setRangeFill(seek, percent.toFixed(2));
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

            seek.addEventListener("input", function () {
                if (!audio.duration) { return; }
                audio.currentTime = (parseFloat(seek.value) / 100) * audio.duration;
                setRangeFill(seek, parseFloat(seek.value).toFixed(2));
            });

            volume.addEventListener("input", function () {
                audio.volume = parseFloat(volume.value);
                audio.muted = audio.volume === 0;
                setRangeFill(volume, (audio.volume * 100).toFixed(0));
            });

            btnMute.addEventListener("click", function () {
                audio.muted = !audio.muted;
                setRangeFill(volume, audio.muted ? 0 : (audio.volume * 100).toFixed(0));
            });

            /* ---------- Botones de reproducción de la lista ---------- */
            rows.forEach(function (row) {
                var button = row.querySelector("[data-play]");
                if (!button) { return; }
                button.addEventListener("click", function () {
                    if (row.getAttribute("data-available") !== "1") { return; }
                    if (currentRow === row) { togglePlayPause(); } else { loadRow(row, true); }
                });
            });

            /* ---------- Buscador instantáneo ---------- */
            var searchInput = document.getElementById("searchInput");
            var noResults = document.getElementById("noResults");
            var btnClearSearch = document.getElementById("btnClearSearch");

            function applyFilter() {
                var term = (searchInput.value || "").toLowerCase().trim();
                var visible = 0;
                rows.forEach(function (row) {
                    var name = (row.getAttribute("data-name") || "").toLowerCase();
                    var match = term === "" || name.indexOf(term) >= 0;
                    row.style.display = match ? "" : "none";
                    if (match) { visible++; }
                });
                if (noResults) { noResults.hidden = !(visible === 0 && rows.length > 0); }
            }

            if (searchInput) {
                searchInput.addEventListener("input", applyFilter);
                searchInput.addEventListener("keydown", function (event) {
                    // The filter is instant, so Enter must not submit the form.
                    if (event.key === "Enter") { event.preventDefault(); }
                });
            }
            if (btnClearSearch) {
                btnClearSearch.addEventListener("click", function () {
                    searchInput.value = "";
                    applyFilter();
                    searchInput.focus();
                });
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
                element.addEventListener("click", function () {
                    closeModal(findModal(element));
                });
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
                    if (searchInput) { searchInput.focus(); }
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

            updatePlayIcon(false);
            audio.volume = 0.8;
        })();
    </script>
</body>
</html>

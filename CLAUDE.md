# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a personal knowledge base (Obsidian vault) containing how-to guides, checklists, and reference documentation in Markdown format. It is not a software project — there are no build, test, or lint commands.

## Git Automation

The obsidian-git plugin auto-commits every 5 minutes with messages like `vault backup: YYYY-MM-DD HH:mm:ss`. Manual commits should follow the same format or use a short descriptive message.

## Content Organization

- `linux/` — Linux/Arch system administration, with `linux/emacs/` for editor-specific docs
- `devel/` — Developer how-tos (Git workflows, Rust setup)
- `events/` — Event notes
- Root — Top-level cheatsheets and cross-cutting references

## Obsidian Conventions

- Internal links use wikilink syntax: `[[note-name]]` or `[[folder/note]]`
- When renaming notes, Obsidian automatically updates all wikilinks (auto-link update is enabled)
- New notes should follow the existing topic-based structure rather than creating a flat root dump

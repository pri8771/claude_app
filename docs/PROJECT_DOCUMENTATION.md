# Hindsight — Project Documentation

> Historical overview. For current lifecycle, scope, architecture, risks, tests,
> release gates, and agent handoff, use the factory-governed documents in this
> directory beginning with `STATUS.md`. Code remains authoritative for implemented
> behavior.

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

## 00. Executive Summary
Hindsight is a private on-device decision journal. Users capture decisions, record predictions, set review reminders, and later compare beliefs to reality. It is for thoughtful professionals, founders, investors, students, and anyone who wants to improve decision quality. The end product should include local storage, capture wizard, review reminders, insights, export, privacy-first messaging, TestFlight beta, and App Store readiness.

## 01. Product
MVP scope: capture wizard, decisions list, review flow, insights, export, settings, local notifications. North Star: decisions reviewed per active user per month.

## 02. Design
Reflective, private, serious but approachable. Screens: Today, Decisions, Capture Wizard, Review, Insights, Settings.

## 03. Frontend Technical
SwiftUI plus SwiftData plus Swift Charts. Models: Decision, DecisionOption, Prediction, OutcomeReview. Notifications optional. Export JSON/PDF.

## 04. Backend Technical
No backend by design for v1. Future optional iCloud-only sync. No account required for MVP.

## 05. Business
Business model: one-time premium, premium insights, optional sync later. Trust and local-first design are core differentiators.

## 06. Marketing
Positioning: remember what you believed before reality gave you the answer. Channels: productivity, decision-making, founder, and investor communities.

## 07. User Acquisition
Beta with founders, professionals, investors, and students. Metrics: first decision captured, prediction added, review completed, insights viewed, export used.

## 08. Execution
Plan: local build, regression, privacy audit, metadata, TestFlight, beta, go/no-go.

## 09. QA
Test capture wizard, persistence, review reminders, insights, export, delete/reset, onboarding, and accessibility.

## 10. Legal / Compliance
Local-first privacy posture. Disclose data handling clearly. Ensure App Store labels match final implementation.

## 11. Operations
Release process: local QA, TestFlight build, beta feedback, App Store submission. Post-launch: iCloud sync, premium insights, templates.

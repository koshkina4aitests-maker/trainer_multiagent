#!/usr/bin/env python3
"""
Generate visual fitness app prototype screens as PNG files.

This script creates simple high-fidelity mockups based on AGENTS3.md.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


WIDTH = 390
HEIGHT = 844
STATUS_H = 44
NAV_H = 68
CONTENT_TOP = STATUS_H + 16
CONTENT_BOTTOM = HEIGHT - NAV_H - 16
OUTPUT_DIR = Path("artifacts/prototypes")


COLORS = {
    "bg": (247, 249, 252),
    "card": (255, 255, 255),
    "text": (23, 31, 53),
    "muted": (116, 125, 150),
    "primary": (66, 99, 235),
    "primary_dark": (44, 74, 199),
    "success": (39, 174, 96),
    "warning": (242, 153, 74),
    "error": (235, 87, 87),
    "border": (225, 231, 240),
}


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


FONT_TITLE = load_font(28, bold=True)
FONT_H2 = load_font(20, bold=True)
FONT_BODY = load_font(15, bold=False)
FONT_SMALL = load_font(13, bold=False)
FONT_BUTTON = load_font(15, bold=True)


def rounded_rect(draw: ImageDraw.ImageDraw, xy: tuple[int, int, int, int], radius: int, fill, outline=None, width: int = 1) -> None:
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def draw_status_bar(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((0, 0, WIDTH, STATUS_H), fill=COLORS["bg"])
    draw.text((18, 13), "9:41", fill=COLORS["text"], font=FONT_SMALL)
    draw.text((WIDTH - 75, 13), "LTE 100%", fill=COLORS["text"], font=FONT_SMALL)


def draw_header(draw: ImageDraw.ImageDraw, title: str, subtitle: str | None = None) -> int:
    y = CONTENT_TOP
    draw.text((20, y), title, fill=COLORS["text"], font=FONT_TITLE)
    y += 40
    if subtitle:
        draw.text((20, y), subtitle, fill=COLORS["muted"], font=FONT_BODY)
        y += 30
    return y


def draw_bottom_nav(draw: ImageDraw.ImageDraw, active: str = "Home") -> None:
    top = HEIGHT - NAV_H
    draw.rectangle((0, top, WIDTH, HEIGHT), fill=(255, 255, 255), outline=COLORS["border"], width=1)
    tabs = ["Home", "Plan", "Workouts", "Progress", "Profile"]
    segment = WIDTH / len(tabs)
    for i, tab in enumerate(tabs):
        x = int(segment * i + segment / 2)
        y = top + 18
        color = COLORS["primary"] if tab == active else COLORS["muted"]
        draw.ellipse((x - 8, y - 8, x + 8, y + 8), fill=color if tab == active else (210, 216, 230))
        draw.text((x - int(draw.textlength(tab, font=FONT_SMALL) / 2), y + 14), tab, fill=color, font=FONT_SMALL)


def draw_card(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int, title: str, body: str = "", accent=None) -> None:
    rounded_rect(draw, (x, y, x + w, y + h), 16, fill=COLORS["card"], outline=COLORS["border"])
    if accent:
        rounded_rect(draw, (x + 12, y + 12, x + 24, y + 24), 6, fill=accent)
    draw.text((x + 34 if accent else x + 16, y + 12), title, fill=COLORS["text"], font=FONT_H2)
    if body:
        draw.text((x + 16, y + 44), body, fill=COLORS["muted"], font=FONT_BODY)


def draw_button(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int, text: str, style: str = "primary") -> None:
    if style == "primary":
        fill, outline, txt = COLORS["primary"], None, (255, 255, 255)
    elif style == "secondary":
        fill, outline, txt = (236, 241, 255), COLORS["primary"], COLORS["primary_dark"]
    elif style == "error":
        fill, outline, txt = COLORS["error"], None, (255, 255, 255)
    else:
        fill, outline, txt = COLORS["card"], COLORS["border"], COLORS["text"]
    rounded_rect(draw, (x, y, x + w, y + h), 14, fill=fill, outline=outline, width=2 if outline else 1)
    tw = int(draw.textlength(text, font=FONT_BUTTON))
    draw.text((x + (w - tw) // 2, y + 14), text, fill=txt, font=FONT_BUTTON)


def canvas() -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (WIDTH, HEIGHT), COLORS["bg"])
    draw = ImageDraw.Draw(image)
    draw_status_bar(draw)
    return image, draw


def save(image: Image.Image, name: str) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT_DIR / f"{name}.png", format="PNG")


def screen_welcome() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Fitness App", "Train smarter. Track faster. Recover better.")
    draw_card(draw, 20, y, 350, 140, "Start your journey", "Personal plans based on your goals and level.", accent=COLORS["primary"])
    draw_button(draw, 20, y + 168, 350, 52, "Get Started", "primary")
    draw_button(draw, 20, y + 230, 350, 52, "I already have an account", "secondary")
    save(image, "01_welcome")


def screen_sign_in() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Sign In", "Welcome back")
    draw_card(draw, 20, y, 350, 186, "Email", "name@example.com")
    rounded_rect(draw, (36, y + 96, 354, y + 146), 12, fill=(249, 251, 255), outline=COLORS["border"])
    draw.text((48, y + 112), "Password", fill=COLORS["muted"], font=FONT_BODY)
    draw.text((20, y + 204), "Forgot password?", fill=COLORS["primary"], font=FONT_BODY)
    draw_button(draw, 20, y + 240, 350, 52, "Sign In", "primary")
    draw_button(draw, 20, y + 302, 350, 52, "Create account", "secondary")
    save(image, "02_sign_in")


def screen_home() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Home", "Friday, Mar 27")
    draw_card(draw, 20, y, 350, 118, "Today's workout", "Full Body Strength · 45 min", accent=COLORS["success"])
    draw_button(draw, 34, y + 64, 140, 40, "Quick Start", "primary")
    draw_button(draw, 184, y + 64, 170, 40, "View Plan", "secondary")
    draw_card(draw, 20, y + 132, 170, 136, "Streak", "12 days", accent=COLORS["warning"])
    draw_card(draw, 200, y + 132, 170, 136, "Calories", "420 kcal", accent=COLORS["error"])
    draw_card(draw, 20, y + 280, 350, 154, "Recommended", "Mobility reset · 12 min", accent=COLORS["primary"])
    draw_bottom_nav(draw, "Home")
    save(image, "03_home")


def screen_plan() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Plan", "Week 13")
    draw_card(draw, 20, y, 350, 116, "Mon · Upper Body", "Completed", accent=COLORS["success"])
    draw_card(draw, 20, y + 128, 350, 116, "Wed · Legs & Core", "Today · 50 min", accent=COLORS["primary"])
    draw_card(draw, 20, y + 256, 350, 116, "Fri · HIIT", "Upcoming · 30 min", accent=COLORS["warning"])
    draw_bottom_nav(draw, "Plan")
    save(image, "04_plan")


def screen_workout_details() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Workout Details", "Legs & Core · 50 min")
    draw_card(draw, 20, y, 350, 100, "Exercises", "1) Squats  2) Lunges  3) Plank")
    draw_card(draw, 20, y + 112, 350, 100, "Equipment", "Bodyweight + dumbbells")
    draw_card(draw, 20, y + 224, 350, 100, "Intensity", "Intermediate")
    draw_button(draw, 20, y + 338, 350, 52, "Start Workout", "primary")
    draw_bottom_nav(draw, "Workouts")
    save(image, "05_workout_details")


def screen_active_workout() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Active Workout", "Exercise 2 of 8")
    draw_card(draw, 20, y, 350, 220, "Alternating Lunges", "00:38 remaining", accent=COLORS["primary"])
    rounded_rect(draw, (40, y + 158, 350, y + 176), 9, fill=(230, 236, 248))
    rounded_rect(draw, (40, y + 158, 230, y + 176), 9, fill=COLORS["primary"])
    draw_button(draw, 20, y + 236, 168, 52, "Pause", "secondary")
    draw_button(draw, 202, y + 236, 168, 52, "Skip", "ghost")
    draw_button(draw, 20, y + 300, 350, 52, "Complete Exercise", "primary")
    draw_bottom_nav(draw, "Workouts")
    save(image, "06_active_workout")


def screen_summary() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Workout Complete", "Great job! Keep momentum.")
    draw_card(draw, 20, y, 350, 130, "Session stats", "47 min · 386 kcal · 8 exercises", accent=COLORS["success"])
    draw_card(draw, 20, y + 142, 350, 104, "Feeling", "Moderate effort (RPE 6/10)")
    draw_button(draw, 20, y + 258, 350, 52, "Save & Continue", "primary")
    draw_button(draw, 20, y + 320, 350, 52, "Share Result", "secondary")
    draw_bottom_nav(draw, "Progress")
    save(image, "07_post_workout_summary")


def screen_progress() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Progress", "Last 30 days")
    draw_card(draw, 20, y, 350, 150, "Training consistency", "18 sessions · +20% vs previous period")
    for i, value in enumerate([60, 78, 52, 85, 71, 90]):
        x0 = 40 + i * 54
        y0 = y + 122
        rounded_rect(draw, (x0, y0 - value, x0 + 24, y0), 6, fill=COLORS["primary"])
    draw_card(draw, 20, y + 162, 170, 126, "Weight", "-1.8 kg", accent=COLORS["success"])
    draw_card(draw, 200, y + 162, 170, 126, "VO2", "+4.2%", accent=COLORS["warning"])
    draw_bottom_nav(draw, "Progress")
    save(image, "08_progress")


def screen_profile() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Profile", "Alex Morgan")
    draw_card(draw, 20, y, 350, 92, "Membership", "Pro · renews on Apr 27")
    draw_card(draw, 20, y + 104, 350, 76, "Goals", "Muscle gain · Endurance")
    draw_card(draw, 20, y + 192, 350, 76, "Notifications", "Enabled")
    draw_card(draw, 20, y + 280, 350, 76, "Connected apps", "Apple Health, Garmin")
    draw_button(draw, 20, y + 370, 350, 52, "Edit Profile", "primary")
    draw_bottom_nav(draw, "Profile")
    save(image, "09_profile")


def screen_empty() -> None:
    image, draw = canvas()
    y = draw_header(draw, "No Workouts Yet", "Let's build your first plan.")
    rounded_rect(draw, (95, y + 20, 295, y + 220), 24, fill=(236, 241, 255), outline=COLORS["border"])
    draw.text((130, y + 110), "Empty State", fill=COLORS["muted"], font=FONT_H2)
    draw_button(draw, 20, y + 246, 350, 52, "Create My Plan", "primary")
    draw_bottom_nav(draw, "Plan")
    save(image, "10_empty_state")


def screen_offline() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Offline Mode", "Connection is unavailable.")
    draw_card(draw, 20, y, 350, 130, "Cached workout", "You can continue your last downloaded workout.", accent=COLORS["warning"])
    draw_button(draw, 20, y + 146, 350, 52, "Continue Offline", "secondary")
    draw_button(draw, 20, y + 208, 350, 52, "Retry Connection", "primary")
    draw_bottom_nav(draw, "Home")
    save(image, "11_offline_state")


def screen_api_error() -> None:
    image, draw = canvas()
    y = draw_header(draw, "Something Went Wrong", "We couldn't save your workout.")
    draw_card(draw, 20, y, 350, 124, "Error code", "API_503_TEMP_UNAVAILABLE", accent=COLORS["error"])
    draw_button(draw, 20, y + 138, 350, 52, "Retry", "error")
    draw_button(draw, 20, y + 200, 350, 52, "Save Locally", "secondary")
    draw_bottom_nav(draw, "Workouts")
    save(image, "12_api_error")


@dataclass(frozen=True)
class Screen:
    name: str
    fn: callable


def all_screens() -> Iterable[Screen]:
    return [
        Screen("welcome", screen_welcome),
        Screen("sign_in", screen_sign_in),
        Screen("home", screen_home),
        Screen("plan", screen_plan),
        Screen("workout_details", screen_workout_details),
        Screen("active_workout", screen_active_workout),
        Screen("summary", screen_summary),
        Screen("progress", screen_progress),
        Screen("profile", screen_profile),
        Screen("empty", screen_empty),
        Screen("offline", screen_offline),
        Screen("api_error", screen_api_error),
    ]


def main() -> None:
    for screen in all_screens():
        screen.fn()
    print(f"Generated {len(list(all_screens()))} screens in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()

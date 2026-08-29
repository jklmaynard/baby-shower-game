const TIMER_SECONDS = 30;

class TriviGame {
  constructor(container) {
    this.container = container;
    this.playerId = container.dataset.playerId;
    this.wrapper = container.querySelector("#slides-wrapper");
    this.slides = container.querySelectorAll(".slide");
    this.currentIndex = 0;
    this.timers = {};
    this.answered = {};
    this.correctCount = 0;
    this.totalQuestions = this.slides.length - 1; // exclude end slide

    this.bindEvents();
    this.startSlide(0);
  }

  // ── Navigation ──────────────────────────────────────

  goToSlide(index) {
    if (index < 0 || index >= this.slides.length) return;
    this.currentIndex = index;
    this.wrapper.style.transform = `translateX(-${index * 100}vw)`;
    if (index < this.slides.length - 1) {
      this.startSlide(index);
    } else {
      this.showEndScore();
    }
  }

  showEndScore() {
    const el = document.getElementById("end-score");
    if (el) el.textContent = `Your score: ${this.correctCount}/${this.totalQuestions}`;
  }

  nextSlide() {
    this.goToSlide(this.currentIndex + 1);
  }

  // ── Timer ────────────────────────────────────────────

  startSlide(index) {
    const slide = this.slides[index];
    if (!slide || slide.classList.contains("slide-end")) return;
    const qid = slide.dataset.questionId;
    if (!qid || this.timers[qid]) return;

    const bar = slide.querySelector(`.timer-bar`);
    const label = slide.querySelector(`.timer-label`);
    if (!bar || !label) return;

    let remaining = TIMER_SECONDS;
    label.textContent = this.formatTime(remaining);

    this.timers[qid] = setInterval(() => {
      remaining--;
      label.textContent = this.formatTime(remaining);
      bar.style.width = `${(remaining / TIMER_SECONDS) * 100}%`;

      if (remaining <= 10) bar.classList.add("warning");

      if (remaining <= 0) {
        clearInterval(this.timers[qid]);
        label.textContent = "Time's up!";
        this.onTimeUp(index, slide, qid);
      }
    }, 1000);
  }

  stopTimer(qid) {
    if (this.timers[qid]) {
      clearInterval(this.timers[qid]);
      delete this.timers[qid];
    }
  }

  formatTime(s) {
    return `0:${s.toString().padStart(2, "0")}`;
  }

  onTimeUp(index, slide, qid) {
    this.lockAnswers(slide);
    setTimeout(() => this.flipCard(slide, index), 600);
  }

  // ── Answer submission ────────────────────────────────

  async submitAnswer(qid, answerText, slide) {
    if (this.answered[qid]) return;
    this.answered[qid] = true;
    this.stopTimer(qid);

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    try {
      const res = await fetch("/api/answers", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ question_id: qid, answer_text: answerText }),
      });
      const data = await res.json();

      if (data.success !== undefined) {
        this.highlightAnswer(slide, answerText, data.is_correct);
        if (data.is_correct) this.correctCount++;
      }
    } catch (e) {
      console.error("Answer submission failed", e);
    }

    setTimeout(() => {
      const idx = parseInt(slide.dataset.index);
      this.flipCard(slide, idx);
    }, 1200);
  }

  highlightAnswer(slide, answerText, isCorrect) {
    const btns = slide.querySelectorAll(".answer-btn");
    btns.forEach((btn) => {
      btn.classList.add("disabled");
      if (btn.dataset.answer === answerText) {
        btn.classList.add(isCorrect ? "correct" : "incorrect");
      }
    });
  }

  lockAnswers(slide) {
    slide.querySelectorAll(".answer-btn").forEach((b) => b.classList.add("disabled"));
    [".blank-input", ".date-input"].forEach((sel) => {
      const el = slide.querySelector(sel);
      if (el) el.disabled = true;
    });
    [".submit-blank-btn", ".submit-date-btn"].forEach((sel) => {
      const el = slide.querySelector(sel);
      if (el) el.disabled = true;
    });
  }

  // ── Card flip ────────────────────────────────────────

  flipCard(slide, index) {
    slide.querySelector(".slide-inner").classList.add("is-flipped");
    this.burstConfetti(slide);
  }

  burstConfetti(slide) {
    const colors = ["#f8c8d4", "#c8e8d8", "#dccff0", "#fff4c2", "#fde4cc"];
    const rect = slide.getBoundingClientRect();
    for (let i = 0; i < 12; i++) {
      const piece = document.createElement("div");
      piece.className = "confetti-piece";
      piece.style.cssText = `
        left: ${rect.left + Math.random() * rect.width}px;
        top: ${rect.top + Math.random() * 0.4 * rect.height}px;
        background: ${colors[Math.floor(Math.random() * colors.length)]};
        animation-delay: ${Math.random() * 0.3}s;
      `;
      document.body.appendChild(piece);
      setTimeout(() => piece.remove(), 1200);
    }
  }

  // ── Swipe / drag detection ───────────────────────────

  bindEvents() {
    // Touch swipe
    let touchStartX = null;
    let touchStartY = null;

    this.container.addEventListener("touchstart", (e) => {
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
    }, { passive: true });

    this.container.addEventListener("touchend", (e) => {
      if (touchStartX === null) return;
      const dx = touchStartX - e.changedTouches[0].clientX;
      const dy = Math.abs(touchStartY - e.changedTouches[0].clientY);
      if (Math.abs(dx) > 60 && Math.abs(dx) > dy) {
        if (dx > 0) this.handleSwipeLeft();
      }
      touchStartX = null;
    }, { passive: true });

    // Answer buttons
    this.container.addEventListener("click", (e) => {
      const btn = e.target.closest(".answer-btn");
      if (btn && !btn.classList.contains("disabled")) {
        const slide = btn.closest(".slide");
        const qid = btn.dataset.questionId;
        btn.classList.add("selected");
        this.lockAnswers(slide);
        this.submitAnswer(qid, btn.dataset.answer, slide);
      }

      const submitBtn = e.target.closest(".submit-blank-btn");
      if (submitBtn) {
        const qid = submitBtn.dataset.questionId;
        const slide = submitBtn.closest(".slide");
        const input = slide.querySelector(`.blank-input[data-question-id="${qid}"]`);
        const val = input?.value.trim();
        if (val) {
          submitBtn.disabled = true;
          input.disabled = true;
          this.submitAnswer(qid, val, slide);
        }
      }

      const submitDateBtn = e.target.closest(".submit-date-btn");
      if (submitDateBtn) {
        const qid = submitDateBtn.dataset.questionId;
        const slide = submitDateBtn.closest(".slide");
        const input = slide.querySelector(`.date-input[data-question-id="${qid}"]`);
        const val = input?.value; // ISO format: YYYY-MM-DD
        if (val) {
          this.lockAnswers(slide);
          this.submitAnswer(qid, val, slide);
        }
      }
    });

    // Keyboard (desktop dev convenience)
    document.addEventListener("keydown", (e) => {
      if (e.key === "ArrowRight") this.handleSwipeLeft();
    });
  }

  handleSwipeLeft() {
    const slide = this.slides[this.currentIndex];
    if (!slide || slide.classList.contains("slide-end")) return;

    const inner = slide.querySelector(".slide-inner");
    if (inner.classList.contains("is-flipped")) {
      this.nextSlide();
    }
  }
}

document.addEventListener("turbo:load", () => {
  const container = document.getElementById("game-container");
  if (container && !container.dataset.gameInitialized) {
    container.dataset.gameInitialized = "true";
    new TriviGame(container);
  }
});

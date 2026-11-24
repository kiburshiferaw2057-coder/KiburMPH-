(() => {
  const STORAGE_KEY = "bingo_et_v3_receipt_history";
  const LANG_KEY = "bingo_et_v3_language";

  const accountCardsEl = document.getElementById("payment-cards");
  const selectEl = document.getElementById("payment-select");
  const formEl = document.getElementById("receipt-form");
  const receiptInputEl = document.getElementById("receipt-input");
  const amountInputEl = document.getElementById("amount-input");
  const feedbackEl = document.getElementById("receipt-feedback");
  const historyListEl = document.getElementById("receipt-history-list");
  const clearHistoryBtn = document.getElementById("clear-history-btn");
  const timerChipEl = document.getElementById("round-timer-chip");
  const langSelectEl = document.getElementById("language-select");

  function getSavedLanguage() {
    try {
      const saved = localStorage.getItem(LANG_KEY);
      if (saved && typeof BINGO_ET_I18N !== "undefined" && BINGO_ET_I18N[saved]) {
        return saved;
      }
    } catch (_) {}
    return (typeof BINGO_ET_CONFIG !== "undefined" && BINGO_ET_CONFIG.defaultLanguage) || "am";
  }

  let currentLang = getSavedLanguage();

  function t(key) {
    const dict = (typeof BINGO_ET_I18N !== "undefined" && BINGO_ET_I18N[currentLang]) || {};
    const fallback = (typeof BINGO_ET_I18N !== "undefined" && BINGO_ET_I18N.en) || {};
    return dict[key] || fallback[key] || key;
  }

  function sanitizeText(raw) {
    return String(raw || "").replace(/[<>]/g, "").trim();
  }

  function applyLanguage(langCode) {
    if (typeof BINGO_ET_I18N === "undefined" || !BINGO_ET_I18N[langCode]) {
      langCode = "en";
    }
    currentLang = langCode;
    try {
      localStorage.setItem(LANG_KEY, currentLang);
    } catch (_) {}

    const dict = BINGO_ET_I18N[currentLang];
    document.documentElement.lang = currentLang === "other" ? "en" : currentLang;
    document.documentElement.dir = dict.dir || "ltr";

    if (langSelectEl && langSelectEl.value !== currentLang) {
      langSelectEl.value = currentLang;
    }

    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const key = el.getAttribute("data-i18n");
      if (!key) return;
      if (key === "c1Body" || key === "c2Body" || key === "c3Body" || key === "c4Body") {
        el.innerHTML = t(key);
      } else {
        el.textContent = t(key);
      }
    });

    if (receiptInputEl) receiptInputEl.placeholder = t("receiptPlaceholder");
    if (amountInputEl) amountInputEl.placeholder = t("amountPlaceholder");

    const clarifyCards = document.querySelectorAll(".clarify-card");
    const keys = [
      ["c1Title", "c1Body"],
      ["c2Title", "c2Body"],
      ["c3Title", "c3Body"],
      ["c4Title", "c4Body"]
    ];
    clarifyCards.forEach((card, idx) => {
      if (!keys[idx]) return;
      const h3 = card.querySelector("h3");
      const p = card.querySelector("p");
      if (h3) h3.textContent = t(keys[idx][0]);
      if (p) p.innerHTML = t(keys[idx][1]);
    });

    renderAccounts();
    renderHistory();
    updateCountdown();
  }

  function renderAccounts() {
    if (!accountCardsEl || !selectEl) return;
    const prevSelected = selectEl.value;
    accountCardsEl.textContent = "";
    selectEl.textContent = "";

    BINGO_ET_CONFIG.paymentAccounts.forEach((acc) => {
      const card = document.createElement("div");
      card.className = "account-card";

      const top = document.createElement("div");
      const methodEl = document.createElement("div");
      methodEl.className = "account-method";
      methodEl.textContent = acc.label;

      const numEl = document.createElement("div");
      numEl.className = "account-number";
      numEl.textContent = acc.accountNumber;

      const holderEl = document.createElement("div");
      holderEl.className = "account-holder-sm";
      holderEl.textContent = acc.accountHolder;

      top.append(methodEl, numEl, holderEl);

      const copyBtn = document.createElement("button");
      copyBtn.type = "button";
      copyBtn.className = "btn-copy";
      copyBtn.textContent = `${t("copyName").split(" ")[0]} ${acc.method}`;
      copyBtn.addEventListener("click", () => copyToClipboard(acc.accountNumber, acc.label));

      card.append(top, copyBtn);
      accountCardsEl.appendChild(card);

      const opt = document.createElement("option");
      opt.value = `${acc.method} (${acc.accountNumber})`;
      opt.textContent = `${acc.method} — ${acc.accountNumber}`;
      selectEl.appendChild(opt);
    });

    if (prevSelected) {
      selectEl.value = prevSelected;
    }
  }

  async function copyToClipboard(text, label) {
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text);
      } else {
        const ta = document.createElement("textarea");
        ta.value = text;
        ta.setAttribute("readonly", "");
        ta.style.position = "absolute";
        ta.style.left = "-9999px";
        document.body.appendChild(ta);
        ta.select();
        document.execCommand("copy");
        document.body.removeChild(ta);
      }
      showFeedback("ok", `${t("copyPrefix")} ${label}: ${text}`);
    } catch (_) {
      showFeedback("err", `${t("copyFailPrefix")}: ${text}`);
    }
  }

  function showFeedback(type, message) {
    if (!feedbackEl) return;
    feedbackEl.className = `feedback-box ${type === "ok" ? "ok" : "err"}`;
    feedbackEl.textContent = message;
  }

  function loadHistory() {
    try {
      const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
      return Array.isArray(parsed) ? parsed : [];
    } catch (_) {
      return [];
    }
  }

  function saveHistory(items) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(items.slice(0, 20)));
    } catch (_) {}
  }

  function renderHistory() {
    if (!historyListEl) return;
    const items = loadHistory();
    historyListEl.textContent = "";

    if (!items.length) {
      const emptyLi = document.createElement("li");
      emptyLi.className = "history-item";
      emptyLi.textContent = t("emptyHistory");
      historyListEl.appendChild(emptyLi);
      return;
    }

    items.forEach((item) => {
      const li = document.createElement("li");
      li.className = "history-item";

      const left = document.createElement("div");
      const refStrong = document.createElement("strong");
      refStrong.textContent = item.receipt;
      const metaSpan = document.createElement("div");
      metaSpan.className = "account-holder-sm";
      metaSpan.textContent = `${item.channel}${item.amount ? ` • ${item.amount} ${t("birrSuffix")}` : ""}`;
      left.append(refStrong, metaSpan);

      const right = document.createElement("span");
      right.className = "chip chip-soft";
      right.textContent = t("statusLogged");

      li.append(left, right);
      historyListEl.appendChild(li);
    });
  }

  if (formEl) {
    formEl.addEventListener("submit", (e) => {
      e.preventDefault();
      const cleanRef = sanitizeText(receiptInputEl.value);
      const cleanChannel = sanitizeText(selectEl.value);
      const rawAmount = amountInputEl.value.trim();

      if (!cleanRef || cleanRef.length < 4) {
        showFeedback("err", t("errShortReceipt"));
        return;
      }

      let formattedAmount = "";
      if (rawAmount !== "") {
        const num = Number(rawAmount);
        if (!Number.isFinite(num) || num <= 0) {
          showFeedback("err", t("errInvalidAmount"));
          return;
        }
        formattedAmount = num.toFixed(2);
      }

      const entry = {
        receipt: cleanRef,
        channel: cleanChannel,
        amount: formattedAmount,
        status: "Logged",
        timestamp: new Date().toISOString()
      };

      const updated = [entry, ...loadHistory()];
      saveHistory(updated);
      renderHistory();
      receiptInputEl.value = "";
      amountInputEl.value = "";
      const okMsg = t("okReceiptLogged")
        .replace("{ref}", cleanRef)
        .replace("{holder}", BINGO_ET_CONFIG.accountHolder);
      showFeedback("ok", okMsg);
    });
  }

  if (clearHistoryBtn) {
    clearHistoryBtn.addEventListener("click", () => {
      saveHistory([]);
      renderHistory();
      showFeedback("ok", t("okHistoryCleared"));
    });
  }

  document.querySelectorAll("[data-copy]").forEach((btn) => {
    btn.addEventListener("click", () => {
      copyToClipboard(btn.getAttribute("data-copy"), btn.getAttribute("data-label") || "Value");
    });
  });

  if (langSelectEl) {
    langSelectEl.addEventListener("change", (e) => {
      applyLanguage(e.target.value);
    });
  }

  function updateCountdown() {
    const period = BINGO_ET_CONFIG.roundIntervalSeconds || 120;
    const nowSec = Math.floor(Date.now() / 1000);
    const remaining = period - (nowSec % period);
    const mins = String(Math.floor(remaining / 60)).padStart(2, "0");
    const secs = String(remaining % 60).padStart(2, "0");
    if (timerChipEl) {
      timerChipEl.textContent = `${t("nextRoundPrefix")} ${mins}:${secs}`;
    }
  }

  applyLanguage(currentLang);
  setInterval(updateCountdown, 1000);
})();

import 'package:flutter/material.dart';

/// Simple map-based localization — no codegen needed.
class S {
  S._();

  static String _lang = 'en';

  static void setLocale(Locale locale) => _lang = locale.languageCode;

  // Helper
  static String _t(String en, String uz) => _lang == 'uz' ? uz : en;

  // ── Common ───────────────────────────────────────────────────────────────
  static String get appName => 'HiLight';
  static String get save => _t('Save', 'Saqlash');
  static String get cancel => _t('Cancel', 'Bekor qilish');
  static String get delete => _t('Delete', 'O\'chirish');
  static String get edit => _t('Edit', 'Tahrirlash');
  static String get close => _t('Close', 'Yopish');
  static String get search => _t('Search', 'Qidirish');
  static String get done => _t('Done', 'Tayyor');
  static String get yes => _t('Yes', 'Ha');
  static String get no => _t('No', 'Yo\'q');

  // ── Bottom nav ──────────────────────────────────────────────────────────
  static String get navHome => _t('Home', 'Bosh sahifa');
  static String get navLibrary => _t('Library', 'Kutubxona');
  static String get navInsights => _t('Insights', 'Tushunchalar');
  static String get navProfile => _t('Profile', 'Profil');

  // ── Onboarding ──────────────────────────────────────────────────────────
  static String get onboardTitle1 => _t('Welcome to\nHiLight', 'HiLight ga\nXush kelibsiz');
  static String get onboardSub1 => _t('Your AI-powered reading companion', 'AI yordamida o\'qish hamrohi');
  static String get onboardDesc1 => _t(
    'Transform how you read, learn, and organize knowledge with the help of artificial intelligence.',
    'Sun\'iy intellekt yordamida o\'qish, o\'rganish va bilimlarni tartibga solish usulini o\'zgartiring.',
  );
  static String get onboardTitle2 => _t('Meet HiLight\nYour AI Tutor', 'HiLight —\nAI Tutoring');
  static String get onboardSub2 => _t('Scan • Listen • Summarize • Learn', 'Skanerlash • Tinglash • Xulosa • O\'rganish');
  static String get onboardDesc2 => _t(
    'OCR scanning, voice notes, AI summaries, quiz generation — all powered by HiLight, your personal study assistant.',
    'OCR skanerlash, ovozli yozuvlar, AI xulosalar, test yaratish — barchasi HiLight yordamida.',
  );
  static String get onboardTitle3 => _t('Start Your\nJourney', 'Sayohatingizni\nBoshlang');
  static String get onboardSub3 => _t('Knowledge at your fingertips', 'Bilim qo\'l ostingizda');
  static String get onboardDesc3 => _t(
    'Highlight what matters, let AI organize the rest. Your learning journey begins now.',
    'Muhim narsalarni belgilang, qolganini AI tartibga solsin. O\'rganish sayohatingiz boshlanmoqda.',
  );
  static String get skip => _t('Skip', 'O\'tkazib yuborish');
  static String get getStarted => _t('Get Started', 'Boshlash');
  static String get continueBtn => _t('Continue', 'Davom etish');

  // ── Home ────────────────────────────────────────────────────────────────
  static String get askLumiHint => _t('Ask Lumi anything about this book…', 'Lumi dan bu kitob haqida so\'rang…');
  static String get savedToInsights => _t('Saved to Insights', 'Tushunchalarga saqlandi');
  static String get newEntry => _t('New Entry', 'Yangi yozuv');

  // ── Cards ───────────────────────────────────────────────────────────────
  static String get scannedQuote => _t('Scanned Quote', 'Skanerlangan iqtibos');
  static String get voiceNote => _t('Voice Note', 'Ovozli yozuv');
  static String get aiInsight => _t('AI Insight', 'AI tushuncha');
  static String get manualNote => _t('Manual Note', 'Qo\'lda yozuv');
  static String get summary => _t('Summary', 'Xulosa');

  // ── Insights screen ─────────────────────────────────────────────────────
  static String get insights => _t('Insights', 'Tushunchalar');
  static String get timelineArchive => _t('Timeline & Archive', 'Vaqt chizig\'i va Arxiv');
  static String get noInsightsYet => _t('No insights or notes yet.', 'Hozircha tushuncha yoki yozuv yo\'q.');
  static String get thisWeek => _t('This week', 'Bu hafta');
  static String get booksRead => _t('Books read', 'O\'qilgan kitoblar');
  static String get streak => _t('Streak', 'Ketma-ketlik');
  static String get deleteNote => _t('Delete note?', 'Yozuvni o\'chirish?');
  static String get deleteNoteConfirm => _t(
    'This action cannot be undone. The note will be permanently removed.',
    'Bu amalni qaytarib bo\'lmaydi. Yozuv butunlay o\'chiriladi.',
  );
  static String get noteDeleted => _t('Note deleted', 'Yozuv o\'chirildi');

  // ── Edit note screen ────────────────────────────────────────────────────
  static String get editEntry => _t('Edit Entry', 'Yozuvni tahrirlash');
  static String get contentEmpty => _t('Content cannot be empty.', 'Kontent bo\'sh bo\'lishi mumkin emas.');
  static String get editQuote => _t('Edit the quote…', 'Iqtibosni tahrirlang…');
  static String get editNote => _t('Edit your note…', 'Yozuvni tahrirlang…');
  static String get editTranscript => _t('Edit transcript…', 'Transkripsiyani tahrirlang…');
  static String get editSummary => _t('Edit summary…', 'Xulosani tahrirlang…');
  static String get bookTitle => _t('Book Title', 'Kitob nomi');
  static String get title => _t('Title', 'Sarlavha');

  // ── Create content screen ───────────────────────────────────────────────
  static String get note => _t('Note', 'Yozuv');
  static String get quote => _t('Quote', 'Iqtibos');
  static String get titleOptional => _t('Title (Optional)', 'Sarlavha (ixtiyoriy)');
  static String get bookTitleOptional => _t('Book Title (Optional)', 'Kitob nomi (ixtiyoriy)');
  static String get typeQuoteHere => _t('Type the quote here...', 'Iqtibosni shu yerga yozing...');
  static String get startWritingNote => _t('Start writing your note...', 'Yozuvni yozishni boshlang...');
  static String get emptyContentWarning => _t('Please enter some content before saving.', 'Saqlashdan oldin kontent kiriting.');

  // ── Library screen ──────────────────────────────────────────────────────
  static String get library => _t('Library', 'Kutubxona');
  static String get searchBooks => _t('Search books...', 'Kitoblarni qidirish...');
  static String highlights(String count) => _t('$count highlights', '$count belgilar');

  // ── Lumi Chat ───────────────────────────────────────────────────────────
  static String get lumiName => 'Lumi';
  static String get aiAssistant => _t('AI Assistant', 'AI Yordamchi');
  static String get clearChat => _t('Clear chat', 'Chatni tozalash');
  static String get askLumiAnything => _t('Ask Lumi anything…', 'Lumi dan istalgan narsa so\'rang…');

  // AI modes
  static String get modeOcr => _t('OCR', 'OCR');
  static String get modeSpeech => _t('Speech', 'Nutq');
  static String get modeSummarize => _t('Summarize', 'Xulosa');
  static String get modeQuestions => _t('Questions', 'Savollar');
  static String get modeTutor => _t('Tutor', 'O\'qituvchi');
  static String get modeOrganize => _t('Organize', 'Tartibga solish');

  static String get hintOcr => _t('Scan text from an image…', 'Rasmdan matnni skanerlash…');
  static String get hintSpeech => _t('Describe what you want to transcribe…', 'Nima yozib olishni xohlayotganingizni tasvirlab bering…');
  static String get hintSummarize => _t('Paste or select text to summarize…', 'Xulosa qilish uchun matnni kiriting yoki tanlang…');
  static String get hintQuestions => _t('Generate questions from this material…', 'Bu materialdan savollar yarating…');
  static String get hintTutor => _t('What would you like to learn?', 'Nimani o\'rganmoqchisiz?');
  static String get hintOrganize => _t('Describe how to organize your notes…', 'Yozuvlarni qanday tartibga solishni tasvirlang…');

  // AI responses
  static String get aiRespOcr => _t('Ready to scan! Please share an image and I\'ll extract the text for you.', 'Skanerlashga tayyor! Rasm yuboring, matnni ajratib beraman.');
  static String get aiRespSpeech => _t('Listening… Tap the mic to start recording your voice note.', 'Tinglamoqda… Ovozli yozuvni boshlash uchun mikrofonga bosing.');
  static String get aiRespSummarize => _t('I\'ll analyze the content and provide a concise summary. One moment…', 'Kontentni tahlil qilib, qisqacha xulosa beraman. Bir lahza…');
  static String get aiRespQuestions => _t('Generating thoughtful questions from your material…', 'Materialingizdan savollar yaratilmoqda…');
  static String get aiRespTutor => _t('Let\'s learn together! I\'ll guide you step by step.', 'Keling, birga o\'rganamiz! Qadamma-qadam yo\'l ko\'rsataman.');
  static String get aiRespOrganize => _t('I\'ll help you structure and categorize your notes.', 'Yozuvlarni tuzilmalash va turkumlashda yordam beraman.');
  static String get aiRespDefault => _t('Let me think about that… I\'ll get back to you shortly!', 'Bu haqda o\'ylab ko\'ray… Tez orada javob beraman!');

  // ── Profile screen ──────────────────────────────────────────────────────
  static String get proPlan => _t('Pro Plan', 'Pro Tarif');
  static String get yearlyReadingGoal => _t('Yearly Reading Goal', 'Yillik O\'qish Maqsadi');
  static String books(int read, int target) => _t('$read / $target books', '$read / $target kitob');
  static String get goalCompleted => _t('🎉 Goal completed!', '🎉 Maqsad bajarildi!');
  static String goalProgress(int pct) => _t('$pct% completed', '$pct% bajarildi');
  static String get greatJob => _t(' — great job!', ' — ajoyib!');
  static String get keepGoing => _t(' — keep going!', ' — davom eting!');

  // Account section
  static String get account => _t('Account', 'Hisob');
  static String get editProfile => _t('Edit Profile', 'Profilni tahrirlash');
  static String get notifications => _t('Notifications', 'Bildirishnomalar');
  static String get privacy => _t('Privacy', 'Maxfiylik');

  // Preferences section
  static String get preferences => _t('Preferences', 'Sozlamalar');
  static String get appearance => _t('Appearance', 'Ko\'rinish');
  static String get language => _t('Language', 'Til');
  static String get syncBackup => _t('Sync & Backup', 'Sinxronizatsiya');

  // About section
  static String get about => _t('About', 'Haqida');
  static String get rateHilight => _t('Rate HiLight', 'HiLight ni baholash');
  static String get helpSupport => _t('Help & Support', 'Yordam');
  static String get appVersion => _t('App Version 1.0.0', 'Ilova versiyasi 1.0.0');

  // Logout
  static String get logOut => _t('Log Out', 'Chiqish');
  static String get logOutQuestion => _t('Log out?', 'Chiqish?');
  static String get logOutMessage => _t(
    'You\'ll need to sign in again to access your account.',
    'Hisobingizga kirish uchun qayta tizimga kirishingiz kerak bo\'ladi.',
  );
  static String get signedOut => _t('Signed out', 'Tizimdan chiqildi');

  // Edit profile screen
  static String get fullName => _t('Full name', 'To\'liq ism');
  static String get email => _t('Email', 'Email');
  static String get bio => _t('Bio', 'Biografiya');
  static String get saveChanges => _t('Save changes', 'O\'zgarishlarni saqlash');
  static String get saved => _t('✓ Saved!', '✓ Saqlandi!');

  // Goal editor
  static String get booksReadSoFar => _t('Books read so far', 'Hozirgacha o\'qilgan kitoblar');
  static String get targetBooks => _t('Target books', 'Maqsadli kitoblar');
  static String get saveGoal => _t('Save goal', 'Maqsadni saqlash');
  static String get goalUpdated => _t('✓ Goal updated!', '✓ Maqsad yangilandi!');

  // Notifications screen
  static String get pushNotifications => _t('Push notifications', 'Bildirishnomalar');
  static String get readingReminders => _t('Reading reminders', 'O\'qish eslatmalari');
  static String get weeklyProgress => _t('Weekly progress report', 'Haftalik taraqqiyot hisoboti');
  static String get newRecommendations => _t('New recommendations', 'Yangi tavsiyalar');
  static String get friendActivity => _t('Friend activity', 'Do\'stlar faoliyati');
  static String get promotions => _t('Promotions & offers', 'Aksiyalar va takliflar');

  // Privacy screen
  static String get publicProfile => _t('Public profile', 'Ommaviy profil');
  static String get publicProfileDesc => _t('Others can find and view your profile', 'Boshqalar profilingizni topishi va ko\'rishi mumkin');
  static String get showReadingActivity => _t('Show reading activity', 'O\'qish faoliyatini ko\'rsatish');
  static String get showReadingActivityDesc => _t('Share what you\'re reading publicly', 'O\'qiyotgan narsangizni ommaga ko\'rsatish');
  static String get readingStatsVisible => _t('Reading stats visible', 'O\'qish statistikasi ko\'rinadi');
  static String get readingStatsVisibleDesc => _t('Let friends see your yearly stats', 'Do\'stlar yillik statistikangizni ko\'rsin');
  static String get dataPersonalization => _t('Data personalization', 'Ma\'lumotlar moslashtirish');
  static String get dataPersonalizationDesc => _t('Use reading data to improve recommendations', 'Tavsiyalarni yaxshilash uchun o\'qish ma\'lumotlarini ishlatish');

  // Appearance screen
  static String get theme => _t('Theme', 'Mavzu');
  static String get light => _t('Light', 'Yorug\'');
  static String get dark => _t('Dark', 'Qorong\'u');
  static String get system => _t('System', 'Tizim');
  static String get textSize => _t('Text size', 'Matn o\'lchami');
  static String get sampleText => _t(
    'The quick brown fox jumps over the lazy dog.',
    'Tez jigarrang tulki dangasa itning ustidan sakradi.',
  );

  // Sync screen
  static String get lastSynced => _t('Last synced: 2 min ago', 'Oxirgi sinxronlash: 2 daqiqa oldin');
  static String get notConnected => _t('Not connected', 'Ulanmagan');
  static String get synced => _t('Synced', 'Sinxronlangan');
  static String get connect => _t('Connect', 'Ulash');
  static String get autoSyncWifi => _t('Auto-sync on Wi-Fi', 'Wi-Fi da avto-sinxronlash');
  static String get syncReadingProgress => _t('Sync reading progress', 'O\'qish jarayonini sinxronlash');
  static String get syncHighlightsNotes => _t('Sync highlights & notes', 'Belgilar va yozuvlarni sinxronlash');
  static String get syncNow => _t('Sync now', 'Hozir sinxronlash');
  static String get syncedSuccessfully => _t('✓ Synced successfully!', '✓ Muvaffaqiyatli sinxronlandi!');

  // Rate screen
  static String get tapStarToRate => _t('Tap a star to rate', 'Baholash uchun yulduzga bosing');
  static String get leaveReview => _t('Leave a review (optional)', 'Sharh qoldiring (ixtiyoriy)');
  static String get submitReview => _t('Submit review', 'Sharhni yuborish');
  static String get thankYou => _t('Thank you!', 'Rahmat!');
  static String get feedbackHelps => _t('Your feedback helps us improve.', 'Fikringiz bizga yaxshilanishga yordam beradi.');
  static String get rateAwful => _t('Awful', 'Dahshat');
  static String get rateNotGreat => _t('Not great', 'Yomon');
  static String get rateOkay => _t('Okay', 'Yaxshi');
  static String get rateGood => _t('Good', 'Zo\'r');
  static String get rateExcellent => _t('Excellent!', 'A\'lo!');

  // Help screen
  static String get faq1q => _t('How do I import books?', 'Kitoblarni qanday import qilaman?');
  static String get faq1a => _t(
    'Go to the Library tab and tap the "+" button. You can import EPUB, PDF, or connect your Kindle account to sync your purchases.',
    'Kutubxona bo\'limiga o\'ting va "+" tugmasini bosing. EPUB, PDF import qilishingiz yoki Kindle hisobingizni ulashingiz mumkin.',
  );
  static String get faq2q => _t('Can I export my highlights?', 'Belgilarni eksport qila olamanmi?');
  static String get faq2a => _t(
    'Yes! Open any book, tap the Highlights tab, and use the export icon in the top-right. You can export as Markdown, Notion, or plain text.',
    'Ha! Istalgan kitobni oching, Belgilar bo\'limiga o\'ting va yuqori o\'ngdagi eksport belgisini bosing. Markdown, Notion yoki oddiy matn sifatida eksport qilishingiz mumkin.',
  );
  static String get faq3q => _t('How does the yearly goal work?', 'Yillik maqsad qanday ishlaydi?');
  static String get faq3a => _t(
    'Set your target on the Profile screen. HiLight counts books you\'ve marked as "Finished" in your library. You can update the goal anytime.',
    'Profil sahifasida maqsadingizni belgilang. HiLight kutubxonangizda "Tugallangan" deb belgilangan kitoblarni hisoblaydi.',
  );
  static String get faq4q => _t('Is there a family plan?', 'Oilaviy tarif bormi?');
  static String get faq4a => _t(
    'Not yet, but it\'s on our roadmap! Subscribe to the newsletter to be notified when family plans launch.',
    'Hali yo\'q, lekin rejamizda bor! Oilaviy tarif chiqsa xabardor bo\'lish uchun yangiliklar byulleteniga obuna bo\'ling.',
  );
  static String get contactSupport => _t('Contact support', 'Qo\'llab-quvvatlashga murojaat');

  // Version screen
  static String get readingCompanion => _t('HiLight — Your Reading Companion', 'HiLight — O\'qish Hamrohingiz');
  static String get readMore => _t('Read conversation', 'Suhbatni o\'qish');
}

# App Teardown: How Astrology, Horoscope and Fortune Apps Make Readings Feel Personal

Scope: Co-Star, The Pattern, Sanctuary, Nebula, CHANI, Hint, TimePassages, Astro.com (Astrodienst), and Turkish-market apps (Faladdin, Binnaz Abla, Turkish burç/astroloji apps). Research date: 2026-11-11. Budget-limited pass (about 20 tool calls), so several items stay as gaps. Many "best astrology app 2026" pages in the results are SEO or affiliate blogs written by competing AI-astrology vendors. I used them only where nothing better existed and flagged them.

## 1. What data does each app collect, and when in onboarding?

### Takeaway
Every Western astrology app in scope uses the same core input at the first screen: birth date, birth time and birth place (to build a natal chart). After that they split. Co-Star and The Pattern add a social graph (friends' charts, compatibility "Bonds"). Nebula runs a long marketing-style quiz (20+ steps: interests, gender). Faladdin's key input is a photo of the user's coffee cup. Beyond birth data and contact info, I found little primary documentation of what each app collects.

### Cited Findings
- **Co-Star:** users enter birth date, time and place to generate a chart and daily horoscopes, and can compare their charts and horoscopes with other users (social network). It launched on iOS on 17 Oct 2017, and Android followed in Jan 2020 with a waitlist of 120,000. — [Wikipedia: Co–Star](https://en.wikipedia.org/wiki/Co%E2%80%93Star)
- **The Pattern:** onboarding asks for birthday, birth time and location. Later modules use more data. "Bonds" asks for a friend's or partner's birthday (or a "Custom Profile"). "Connect" is a separate dating profile with its own account. Daily features include a "vibe", a world update and "Pattern reminders". (Bustle, 15 May 2024) — [Bustle](https://www.bustle.com/life/pattern-app-review-features-price)
- **Nebula (OBRIO, Ukraine):** a third-party UX teardown describes onboarding with "over 20 steps". Users pick interests (money, love, career), and the app asks for gender "to tailor relationship guides". The teardown calls it gradual user investment. — [Screensdesign teardown](https://screensdesign.com/showcase/nebula-horoscope-astrology) (secondary source, undated)
- **CHANI:** readings default to the user's **rising sign**, so birth time matters. The company's workaround for users who want a sun-sign reading is to enter the sunrise time of their birth day as the birth time. — [App Store: CHANI](https://apps.apple.com/us/app/-/id1532791252) (summarized via search results)
- **Faladdin (Turkey):** the user drinks Turkish coffee, turns the cup over, photographs it from several angles and uploads the photos. (Hürriyet, Sept 2017) — [Hürriyet](https://www.hurriyet.com.tr/teknoloji/faladdin-nedir-gercek-mi-nasil-kullanilir-40581331). The App Store privacy label lists name, email, photos/videos, identifiers, usage data and purchases (self-reported by the developer). — [App Store TR: Faladdin](https://apps.apple.com/cy/app/faladdin-yapay-zeka-sohbet/id1201725025?l=tr)
- **TimePassages:** the mobile app offers free daily horoscopes and Sun, Moon and Rising meanings from birth data. Deeper reports (compatibility, relationship, astro map, solar return) are paid add-ons. — [App Store: TimePassages](https://apps.apple.com/gb/app/timepassages/id488946918); [TimePassages desktop manual](https://support.astrograph.com/support/solutions/articles/66000476614-desktop-manual-timepassages)

### Inferences
- The industry pattern is: (1) birth data on the first screens, because it is the cheapest input that "unlocks" a seemingly unique chart; (2) relationship data later (friends, partners), which drives virality and return visits; (3) light behavioural signals (daily open, "vibe", chosen interests) that steer which pre-written content is shown rather than generating new content.
- Nebula's 20+ step quiz is mainly a conversion and paywall funnel, sunk-cost style. The interests it collects (love/money/career) also give an easy filter for which content category to put first.

### Gaps
- I found no primary documentation of Faladdin's profile questions. Anecdotally Turkish fal apps ask for name, birth date, relationship status and job, but I could not confirm this in this pass. Verify by installing the app.
- Whether mood journaling or daily check-ins feed text selection is not documented for any app. CHANI offers journal prompts, but I found no evidence they personalize later text.
- I found no first-party onboarding flow for Sanctuary or Hint.

## 2. How is the reading text produced (modular snippets, templates, ephemeris and rules, human astrologers, LLMs)?

### Takeaway
The best-documented model, Co-Star's, is **an ephemeris plus a rules engine plus a large library of human-written snippets that software assembles per user per day**. "AI" in their marketing mostly means this selection and assembly, not free text generation. Legacy players (Astro.com, TimePassages) use the same snippet architecture with **named author texts** per placement, aspect and transit. CHANI sells "made by real astrologers, not AI" as a differentiator. In Turkey, Faladdin describes itself as AI "based on collective predictions of human readers" plus image processing. Its sister app Binnaz Abla used real human readers.

### Cited Findings
- **Co-Star (snippets plus assembly, confirmed by the founder):** "Human writers create snippets for the AI to remember… And then the AI assembles them in real time, according to what may or may not be relevant to you." (Banu Guler, quoted in a Yahoo/Cosmopolitan-style profile) — [Yahoo Lifestyle profile of Banu Guler](https://www.yahoo.com/lifestyle/meet-banu-guler-ceo-co-150000063.html). The founders spent months studying astrology textbooks and talking to astrologers, then fed this into an engine they built. — [Dazed](https://www.dazeddigital.com/life-culture/article/39881/1/costar-is-the-new-astrology-app-banu-guler-vfiles)
- **Co-Star (data source):** the app uses AI to analyze publicly accessible **NASA JPL** data to find patterns in a user's transits. Its algorithm "maps human-written text snippets to planetary movements". — [Wikipedia: Co–Star](https://en.wikipedia.org/wiki/Co%E2%80%93Star). Gizmodo (2020) described the horoscopes as algorithmically generated from human-written insights into NASA data. — [Gizmodo](https://gizmodo.com/android-users-can-finally-get-in-on-co-star-s-brutally-1841067701). The Google Play listing now says real human astrologers "collaborate with AI technology". — [Google Play: Co-Star](https://play.google.com/store/apps/details?id=com.costarastrology&hl=en)
- **Co-Star "The Void" (Q&A feature, 2023):** users type open-ended questions such as "Should I quit my job and move to a different country?" Each answer comes "from a database of astrological interpretations", assembled from the user's most relevant natal placements and current transits, and shown with a diagram of the planets used. Pricing: 3 free questions, then $0.99 for 1, $2.99 for 5, $4.99 for 10. Bustle dates the launch to 4 May 2023. — [Bustle, 23 May 2023](https://www.bustle.com/life/co-star-astrology-app-ai-feature). Wikipedia gives July 2023, citing NYT "Is A.I. the Future of Astrology?" (4 July 2023). — [Wikipedia](https://en.wikipedia.org/wiki/Co%E2%80%93Star). **Conflict:** the two sources give different launch dates, and neither confirms whether an LLM is involved.
- **Co-Star (disputed claim):** a low-authority explainer claims Co-Star uses an LLM to generate new text and does not use NASA data. This contradicts the company's own statements, so treat it as unreliable. — [Inspire/Terabox](https://inspire.terabox.com/hub/why-are-costar-horoscopes-so-mean-and-are-they-actually-accurate)
- **The Pattern:** it calculates a natal chart and converts placements and aspects into psychological descriptions through a "proprietary interpretation system". It shows no glyphs, signs or houses, so users cannot see which placement produced which sentence. (Astrologer review, Apr 2026, written by a competing app vendor, so possibly biased) — [Aurae](https://www.auraeastrology.com/blog/the-pattern-app-review-2026-an-astrologers-honest-opinion). The founder, Lisa Donovan (co-founder of Maker Studios), reportedly tested readings on friends and strangers before launch. — [Bustle 2024](https://www.bustle.com/life/pattern-app-review-features-price); [HandWiki](https://handwiki.org/wiki/Software:The_Pattern_(app))
- **Astro.com (Astrodienst):** its interpretation texts are written by named astrologers. The site cites Liz Greene, Robert Hand and Dana Gerhardt, says Robert Hand "completely rewrote all transit interpretations", and describes Greene as a chief writer. — [Astrodienst](https://www.astro.com/index_e.htm) (via search snippet)
- **TimePassages:** an "interpretation and expert system component" assembles reports from texts by astrologer **Henry Seltzer**. Every report must carry the line "Interpretations by Henry Seltzer", even custom templates. — [TimePassages desktop manual](https://support.astrograph.com/support/solutions/articles/66000476614-desktop-manual-timepassages)
- **CHANI:** the App Store listing says it is "made by real astrologers — not AI". The app was built with AnnieCannons, a firm that trains survivors of human trafficking as developers. — [App Store: CHANI](https://apps.apple.com/us/app/-/id1532791252) (via search results)
- **Nebula:** the headline product is paid live chat with human "advisors" (about 900 according to one secondary source), with generated horoscopes alongside. How much of the content is AI-written is unconfirmed. One App Store review alleges the whole app "is run by AI". — [Supastro (secondary)](https://supastro.com/blog/best-ai-astrology-apps); [Screensdesign](https://screensdesign.com/showcase/nebula-horoscope-astrology)
- **Sanctuary:** sources conflict. Some say daily horoscopes are written by human astrologers, others call it a hybrid of AI daily content and human live chat. — [Rakatarot (secondary)](https://rakatarot.com/free-ai-astrology-app/); [Palmvision (secondary)](https://palmvisionai.com/articles/best-astrology-apps-2026)
- **Faladdin:** uses "kolektif yorumcu öngörülerine dayalı yapay zekâ ve görüntü işleme" (AI and image processing based on the collective predictions of human readers). The predecessor Binnazabla used real people (about 500 staff), and Faladdin replaced them with AI. (Hürriyet, 16 Sept 2017) — [Hürriyet](https://www.hurriyet.com.tr/teknoloji/faladdin-nedir-gercek-mi-nasil-kullanilir-40581331). Faladdin's own terms state that readings are produced only by AI and do not reflect reality. — [Faladdin policy](https://faladdin.com/policy/tr). The current App Store listing frames it as an "AI-supported entertainment, chat and self-awareness" app and adds "Dr. Why", an AI live assistant for love questions. — [App Store TR](https://apps.apple.com/cy/app/faladdin-yapay-zeka-sohbet/id1201725025?l=tr)

### Inferences
- Several architectures exist, but the deterministic snippet library (keyed by planet × sign/house/aspect × transit) is the industry backbone, from Astro.com in the 1990s to Co-Star today. LLM layers, where they exist, sit on top as a Q&A or chat surface (Co-Star's Void, Faladdin's Dr. Why), not as the daily core. This matches the project's own deterministic rule (CLAUDE.md rule 8).
- Faladdin's "collective reader predictions" wording suggests a model trained on, or templated from, a corpus of human readings produced in the Binnaz Abla era. This is inference; the training method is not documented.
- "Made by humans, not AI" has become a selling point (CHANI), so apps that use human-written snippets can say so in their marketing.

### Gaps
- No primary statement on whether Co-Star's Void uses an LLM. The NYT 4 July 2023 article was not fetched.
- No engineering blog posts or job postings found for any app in this pass.
- Hint: the Wikipedia article (flagged as possibly LLM-written) says only "AI and astronomy". The founder is Roman Taranov (Ruby Labs), founded 2018, with a claimed 25M+ users. The generation method is unknown. — [Wikipedia: Hint](https://en.wikipedia.org/wiki/Hint_(app))

## 3. How does The Pattern produce the "scary accurate" reaction?

### Takeaway
The Pattern hides all astrological mechanics and writes in second-person psychological language about inner experiences and relationship dynamics. It names both strengths and painful tensions, and it frames timing as inner "periods" rather than events. Users therefore check the text against how they feel, not against what happened, which is very hard to falsify. Reviewers report feeling "seen". There is no independent validation of accuracy.

### Cited Findings
- No glyphs, zodiac symbols or houses are shown, and insights cannot be traced to placements. — [Aurae review, Apr 2026](https://www.auraeastrology.com/blog/the-pattern-app-review-2026-an-astrologers-honest-opinion)
- Example of the relationship style: "you tend to pursue connection intensely but pull back when it gets too close" (quoted in the Aurae review). This is a classic approach-avoidance dual statement. — [Aurae](https://www.auraeastrology.com/blog/the-pattern-app-review-2026-an-astrologers-honest-opinion)
- Timing wording example: "you may be entering a period of significant internal restructuring". The transit behind it is not named. — [Aurae](https://www.auraeastrology.com/blog/the-pattern-app-review-2026-an-astrologers-honest-opinion)
- More examples from the reading text: "You're a true individual — uniquely yourself." and "Your life works best when you embrace what's unpredictable about it". The reviewer called the experience "more like a therapy session" and said she felt seen. The app covers both strengths and challenges. — [Bustle, 15 May 2024](https://www.bustle.com/life/pattern-app-review-features-price)
- **Contradiction:** Bustle says some astrology terms (transit, Neptune, Mercury retrograde) do appear, mainly in audio and library content, while Aurae says mechanics are hidden. Both may be true: the core personality text is jargon-free, and the secondary content explains astrology. — [Bustle](https://www.bustle.com/life/pattern-app-review-features-price); [Aurae](https://www.auraeastrology.com/blog/the-pattern-app-review-2026-an-astrologers-honest-opinion)
- A 2017 Berkeley podcast also noted the app does not reference planets or the zodiac. — [Cal Alumni "The Edge" Ep. 1](https://alumni.berkeley.edu/california-magazine/the-edge-podcast/the-edge-episode-1-pattern-how-do-you-know-me/)
- The phrase "scarily accurate" is press and user framing (Vanity Fair 2021, Daily Front Row), not a test result. — [Daily Front Row](https://fashionweekdaily.com/soulmates-or-challenging-scarily-accurate-astrology-app-the-pattern-now-has-a-dating-feature/)

### Inferences
- The mechanisms that likely make it work (from the examples, not stated by the company): (a) **dual or contradictory traits** in one sentence (pursue / pull back), so almost anyone recognizes themselves; (b) **inner-state framing** (feel, tend to, need) rather than observable events; (c) **naming a hidden wound** or vulnerability, which reads as intimacy; (d) **no visible source**, so the text reads like knowledge about the person rather than about "Leos"; (e) **timing as a psychological season** ("period of restructuring"), which the user fills with their own current struggle; (f) a clinical, therapy-like UI that signals seriousness.
- These are textbook Barnum/Forer effects. No reviewer in my sources tested them, so this is my inference.

### Gaps
- I did not find The Pattern's own names for its pattern types or the count of distinct text modules.
- No founder interview on the writing method was fetched (the Apple Podcasts interview with Lisa Donovan exists but was not transcribed: [link](https://podcasts.apple.com/ie/podcast/olivia-gets-a-wild-birth-chart-reading-from-the/id1462213019?i=1000524466443)).

## 4. How do apps structure a reading?

### Takeaway
There are three archetypes. **Co-Star** uses terse, blunt daily push lines plus short explanations tied to visible transits (and, from my background knowledge, Do/Don't lists, which I did not verify in this pass). **The Pattern** writes long, jargon-free inner-life portraits plus "Timing" periods. **CHANI** wraps astrology in ritual and self-care formats (rising-sign horoscope, podcast, meditation, affirmations, journal prompts, altar suggestions).

### Cited Findings
- **Co-Star:** press described its voice as "slightly robotic" (The Verge, 2019), "brutally honest" (Newsweek, 2019) and "a free therapy session" (Gizmodo, 2020). Its unconventional daily push notifications are known for their tone. — [Wikipedia: Co–Star](https://en.wikipedia.org/wiki/Co%E2%80%93Star); [Gizmodo](https://gizmodo.com/android-users-can-finally-get-in-on-co-star-s-brutally-1841067701)
- **Co-Star Void:** each answer comes with an interpretation plus a diagram of the planets used, which makes the reasoning visible (the opposite of The Pattern). — [Bustle](https://www.bustle.com/life/co-star-astrology-app-ai-feature)
- **The Pattern sections:** Your Pattern (personality: communication style, relationship history), Your Timing (current and upcoming cycles with dates), Bonds (compatibility), daily vibe and reminders, Time Travel (transits on a chosen date), World Timing, Romantic Patterns, Connect (dating), and a Library (audio, New Moon guides). Pricing: free, then $29.99 per quarter; extra custom profiles cost money. — [Bustle 2024](https://www.bustle.com/life/pattern-app-review-features-price). Aurae says there are no daily horoscopes in the classic sense and calls the "fixed patterns" framing deterministic. — [Aurae](https://www.auraeastrology.com/blog/the-pattern-app-review-2026-an-astrologers-honest-opinion)
- **CHANI:** free tier has daily horoscopes and moon-phase updates. Premium adds birth chart readings, a personalized rising-sign podcast, guided meditations, affirmations, journal prompts, altar suggestions and a year-ahead reading. Pricing: $11.99/month, $107.99/year. — [App Store: CHANI](https://apps.apple.com/us/app/-/id1532791252) (via search summary)
- **Faladdin:** one free reading per day; extra readings and a "faster reading" option cost credits (from 3.49 TL in 2017). — [Hürriyet 2017](https://www.hurriyet.com.tr/teknoloji/faladdin-nedir-gercek-mi-nasil-kullanilir-40581331). The current app adds daily energy and biorhythm tracking, motivational messages, dream interpretation and social features. — [App Store TR](https://apps.apple.com/cy/app/faladdin-yapay-zeka-sohbet/id1201725025?l=tr)

### Inferences
- Showing the reasoning (Co-Star: "because Mars is square your Moon") builds credibility through mechanism. Hiding it (The Pattern) builds credibility through intimacy. Both work. A deterministic score app could show a light "why" (e.g. Moon sign/element relation) while keeping inner-life wording.
- Waiting and scarcity (one free reading per day, paid "faster" reading) are part of how Turkish fal apps package a reading.

### Gaps
- No verified primary source in this pass for Co-Star's Do/Don't list format or exact daily-screen structure. App Store screenshots would confirm it.
- No verbatim Co-Star daily-line examples were retrieved from a citable source.

## 5. How much content volume (snippets, writers on staff)?

### Takeaway
Hard numbers are almost entirely missing from public sources. What exists: Co-Star says human writers write the snippets; Astro.com and TimePassages rely on one or a few named authors who wrote full interpretation libraries; Binnazabla (Faladdin's predecessor) had about 500 staff doing human readings; Nebula has hundreds of chat advisors.

### Cited Findings
- Binnazabla employed about 500 people (2017). — [Hürriyet](https://www.hurriyet.com.tr/teknoloji/faladdin-nedir-gercek-mi-nasil-kullanilir-40581331)
- Robert Hand rewrote all of Astro.com's transit interpretations; Liz Greene is a chief writer. — [Astrodienst](https://www.astro.com/index_e.htm)
- TimePassages' interpretations are by a single author (Henry Seltzer, © 1999 AstroGraph). — [TimePassages manual](https://support.astrograph.com/support/solutions/articles/66000476614-desktop-manual-timepassages)
- Nebula: about 900 human advisors (secondary source, unverified). — [Supastro](https://supastro.com/blog/best-ai-astrology-apps)
- Scale context: Co-Star reported 20M+ downloads (Apr 2021) and raised $15M in a Series A led by Spark Capital ([Wikipedia](https://en.wikipedia.org/wiki/Co%E2%80%93Star)). The Atlantic reported 30M registered accounts, while data.ai estimated about 800k monthly users ([via search summary](https://www.yahoo.com/lifestyle/meet-banu-guler-ceo-co-150000063.html)). Nebula claims 20M+ downloads and was the most downloaded US astrology app in summer 2020 per Sensor Tower ([Wikipedia: Nebula](https://en.wikipedia.org/wiki/Nebula_(spiritual_guidance))). Faladdin claims 25M+ users ([App Store TR](https://apps.apple.com/cy/app/faladdin-yapay-zeka-sohbet/id1201725025?l=tr)).

### Inferences
- A full natal plus transit library is combinatorially bounded. Roughly 10 planets × 12 signs × 12 houses plus major aspects between planet pairs gives a few thousand base entries. That is consistent with one author (Seltzer) or a small team writing a complete library. This is my estimate, not sourced.

### Gaps
- No snippet counts or writer headcount for Co-Star, The Pattern, CHANI, Sanctuary or Hint. Job-posting searches were not run.

## 6. Turkish market: localization, kahve falı vs. astroloji, review themes

### Takeaway
In Turkey, **kahve falı (coffee-cup reading) is the flagship digital fortune format**. Faladdin and its predecessor Binnaz Abla pioneered it, moving from human readers to AI. Astrology apps (Mynet Astroloji, Twitburc, MapAstro, Astrology Master, Ms Astro, plus localized global apps like Nebula and Astroline) compete with smaller rating bases. In Turkish complaint data, **billing and subscription problems dominate, not reading quality**.

### Cited Findings
- Binnaz Abla was described as the first digital kahve falı app; Faladdin comes from the same maker (Sertaç Taşdelen). — [DergiPark academic paper "Dijital Ortamda Fal: Faladdin Uygulaması"](https://www.researchgate.net/publication/361118978_DIJITAL_ORTAMDA_FAL_FALADDIN_UYGULAMASI_Fortune_in_Digital_Environment_Faladdin_Application) (abstract via search); [Hürriyet](https://www.hurriyet.com.tr/teknoloji/faladdin-nedir-gercek-mi-nasil-kullanilir-40581331)
- Faladdin positions itself as entertainment ("not to read fortunes or predict the future") and bundles kahve falı, tarot, astroloji, burç and rüya tabiri (dream interpretation). App Store TR rating: 4.6 from 294 ratings; the visible reviews (2019–2020) praise readings as accurate and the app as fun. — [App Store TR](https://apps.apple.com/cy/app/faladdin-yapay-zeka-sohbet/id1201725025?l=tr)
- Legal risk: an investigation into publisher Sertaç Taşdelen was reported, with asset seizures. Experts said individual entertainment users face no criminal risk. The article date and outcome were not verified. — [Gazete Merhaba](https://gazetemerhaba.com/gundem/milyonlarca-kisi-her-gun-kullaniyor-faladdin-ve-binnaza-sorusturma-fal-baktirmak-suc-mu-95835)
- Critical Turkish commentary: readings impress because of "genel cümleler, kişiye uyarlama, senin yorumlaman" (general sentences, personal adaptation, your own interpretation). — [Ömer Layık blog](https://omerlayik.com.tr/faladdin-nedir-nasil-indirilir-nasil-kullanilir/) (via search summary)
- Şikayetvar complaints: Nebula has 124 complaints, mostly unauthorized charges and hard cancellation ([Şikayetvar Nebula](https://www.sikayetvar.com/nebula-horoscope-astrology/iptal-etme)). Astroline has 24, mostly charges after a $1 trial and subscriptions still active after cancellation ([Şikayetvar Astroline](https://www.sikayetvar.com/astroline)). Ms Astro users report login and access failures ([Şikayetvar Ms Astro](https://www.sikayetvar.com/msastro/ms-astro-uygulamasina-erisim-sorunu-ve-destek-talebi)).
- Local astrology apps have thin rating bases: Mynet Astroloji has 3.7/5 from only 11 US-store ratings ([App Store](https://apps.apple.com/us/app/-/id463445337)), and MapAstro has too few ratings to display ([App Store](https://apps.apple.com/us/app/mapastro/id6475003734)). Others exist: Twitburc ([App Store](https://apps.apple.com/app/id1642898817)), and Astrology Master in Turkish, which claims testing by professional astrologers ([AppFollow TR](https://apps.appfollow.io/ios/astrology-master/1470375553?country=tr)).
- Turkish tech press covered an AI astrology app ("Stellium") under the framing "AI matchmaking astrology" — [ShiftDelete](https://shiftdelete.net/stellium-yapay-zeka-copcatanlik-astroloji?amp=1) (not fetched; headline only).
- Global subscription apps are also under regulatory scrutiny: OBRIO (Nebula) entities were reportedly named in an FTC case about subscription practices (secondary source; status unverified). — [Screensdesign/yespress summary](https://yespress.io/obrio)

### Inferences
- Turkish users have a strong cultural template for fal: a warm, chatty, "abla" (elder sister) narrator who talks about love, an approaching kısmet (fortune or chance), money and the nazar (evil eye). Faladdin's history (human readers, then AI trained on their style) suggests the localized voice matters more than astrological rigor. This comes from the cited history plus cultural background; there is no direct text corpus in this pass.
- Trust in Turkey is fragile around billing. A transparent, non-predatory monetization model can itself set an app apart.
- For a Turkish daily-luck app, the sources point to: a daily ritual (one free reading per day), love/relationship focus, an entertainment disclaimer, and a warm second-person voice.

### Gaps
- I could not extract the full text of the DergiPark Faladdin paper (PDF parsing failed). It reportedly contains a categorized analysis of user reviews, including negative ones, and is worth reading manually: [DergiPark PDF](https://dergipark.org.tr/tr/download/article-file/2376801).
- No large sample of Turkish Google Play reviews for Faladdin or burç apps was collected. Complaints about repetitive or generic readings are plausible but unverified here.
- No verified example of Faladdin reading text.
- No market-share ranking of Turkish astrology apps was found.

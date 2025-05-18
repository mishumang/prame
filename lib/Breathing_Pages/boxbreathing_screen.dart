import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;
import 'dart:math';

class BoxBreathingScreen extends StatefulWidget {
  final int inhaleDuration;  // seconds for Inhale phase
  final int hold1Duration;   // seconds for first Hold phase
  final int exhaleDuration;  // seconds for Exhale phase
  final int hold2Duration;   // seconds for second Hold phase
  final int rounds;          // number of rounds

  const BoxBreathingScreen({
    Key? key,
    required this.inhaleDuration,
    required this.hold1Duration,
    required this.exhaleDuration,
    required this.hold2Duration,
    required this.rounds,
  }) : super(key: key);

  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _inhalePlayer;
  late AudioPlayer _exhalePlayer;
  late AudioPlayer _chalisaPlayer;     // Add this
  late AudioPlayer _adityaMantraPlayer; // Add this
  bool isRunning = false;
  bool isAudioPlaying = true;
  bool isMantraPlaying = false; // Default to true for better UX
  bool showHanumanChalisa = false; // Toggle for Hanuman Chalisa
  bool showAdityaMantra = false; // Toggle for Aditya Mantra
  String breathingText = "Get Ready";
  int _currentRound = 0;
  String _currentPhase = "";
  int _currentVerseIndex = 0;

  // Selected language
  String _selectedLanguage = "Sanskrit"; // Default language

  // Track which sides have been read in current cycle
  Map<String, bool> _sideRead = {
    "top": false,
    "right": false,
    "bottom": false,
    "left": false,
  };
  String _activeSide = "top"; // Current active side

  // Audio sources (ensure these assets exist and update paths accordingly)
  late final AssetSource _inhaleSound;
  late final AssetSource _exhaleSound;
  late final AssetSource _mantraSound;

  // Total duration and phase fractions
  late final double _totalDuration;
  late final double _f1; // end of Inhale phase
  late final double _f2; // end of Hold1 phase
  late final double _f3; // end of Exhale phase
  // _f4 is implicitly 1.0 (end of Hold2 phase)

  // Animation for pulse effect
  late Animation<double> _pulseAnimation;

  // Sanskrit verses (Keep your original _hanumanChalisaVerses and _adityaMantraVerses)
  final List<String> _hanumanChalisaVerses = [
    "श्री गुरु चरन सरोज रज, निज मनु मुकुरु सुधारि",
    "बरनऊं रघुबर बिमल जसु, जो दायकु फल चारि",
    "बुद्धिहीन तनु जानिके, सुमिरौं पवन कुमार",
    "बल बुद्धि विद्या देहु मोहिं, हरहु कलेस विकार",
    "जय हनुमान ज्ञान गुन सागर, जय कपीस तिहुं लोक उजागर",
    "राम दूत अतुलित बल धामा, अंजनि पुत्र पवनसुत नामा",
    "महाबीर विक्रम बजरंगी, कुमति निवार सुमति के संगी",
    "कंचन बरन बिराज सुबेसा, कानन कुंडल कुंचित केसा",
    "हाथ बज्र औ ध्वजा बिराजै, कांधे मूंज जनेऊ साजै",
    "शंकर सुवन केसरी नंदन, तेज प्रताप महा जग बंदन",
    "विद्यावान गुनी अति चातुर, राम काज करिबे को आतुर",
    "प्रभु चरित्र सुनिबे को रसिया, राम लखन सीता मन बसिया",
    "सूक्ष्म रूप धरि सियहिं दिखावा, बिकट रूप धरि लंक जरावा",
    "भीम रूप धरि असुर संहारे, रामचंद्र के काज संवारे",
    "लाय सजीवन लखन जियाये, श्री रघुबीर हरषि उर लाये",
    "रघुपति कीन्ही बहुत बड़ाई, तुम मम प्रिय भरतहि सम भाई",
    "सहस बदन तुम्हरो जस गावैं, अस कहि श्रीपति कंठ लगावैं",
    "सनकादिक ब्रह्मादि मुनीसा, नारद सारद सहित अहीसा",
    "जम कुबेर दिगपाल जहां ते, कबि कोबिद कहि सके कहां ते",
    "तुम उपकार सुग्रीवहिं कीन्हा, राम मिलाय राज पद दीन्हा",
    "तुम्हरो मंत्र विभीषन माना, लंकेश्वर भए सब जग जाना",
    "जुग सहस्र जोजन पर भानू, लील्यो ताहि मधुर फल जानू",
    "प्रभु मुद्रिका मेलि मुख माहीं, जलधि लांघि गये अचरज नाहीं",
    "दुर्गम काज जगत के जेते, सुगम अनुग्रह तुम्हरे तेते",
    "राम दुआरे तुम रखवारे, होत न आज्ञा बिनु पैसारे",
    "सब सुख लहै तुम्हारी सरना, तुम रक्षक काहू को डर ना",
    "आपन तेज सम्हारो आपै, तीनों लोक हांक तें कांपै",
    "भूत पिसाच निकट नहिं आवै, महाबीर जब नाम सुनावै",
    "नासै रोग हरै सब पीरा, जपत निरंतर हनुमत बीरा",
    "संकट तें हनुमान छुड़ावै, मन क्रम बचन ध्यान जो लावै",
    "सब पर राम तपस्वी राजा, तिन के काज सकल तुम साजा",
    "और मनोरथ जो कोई लावै, सोइ अमित जीवन फल पावै",
    "चारों जुग परताप तुम्हारा, है परसिद्ध जगत उजियारा",
    "साधु संत के तुम रखवारे, असुर निकंदन राम दुलारे",
    "अष्ट सिद्धि नौ निधि के दाता, अस बर दीन जानकी माता",
    "राम रसायन तुम्हरे पासा, सदा रहो रघुपति के दासा",
    "तुम्हरे भजन राम को पावै, जनम जनम के दुख बिसरावै",
    "अन्तकाल रघुबर पुर जाई, जहां जन्म हरि भक्त कहाई",
    "और देवता चित्त न धरई, हनुमत सेई सर्व सुख करई",
    "संकट कटै मिटै सब पीरा, जो सुमिरै हनुमत बलबीरा",
    "जै जै जै हनुमान गोसाईं, कृपा करहु गुरुदेव की नाईं",
    "जो सत बार पाठ कर कोई, छूटहि बंदि महा सुख होई",
    "जो यह पढ़ै हनुमान चालीसा, होय सिद्धि साखी गौरीसा",
    "तुलसीदास सदा हरि चेरा, कीजै नाथ हृदय मंह डेरा",
  ];

  // ADD YOUR SANSKRIT HANUMAN CHALISA VERSES HERE
  // These are already in your original code

  final List<String> _adityaMantraVerses = [
    "ओम अस्य आदित्यह्रदय स्तोत्रस्य अगस्त्यऋषि: अनुष्टुप्छन्दः",
    "आदित्यह्रदयभूतो भगवान् ब्रह्मा देवता निरस्ताशेषविघ्नतया",
    "ब्रह्माविद्यासिद्धौ सर्वत्र जयसिद्धौ च विनियोगः।",
    "ततो युद्धपरिश्रान्तं समरे चिन्तया स्थितम्‌।",
    "रावणं चाग्रतो दृष्ट्वा युद्धाय समुपस्थितम्‌।",
    "दैवतैश्च समागम्य द्रष्टुमभ्यागतो रणम्‌।",
    "उपगम्याब्रवीद् राममगस्त्यो भगवांस्तदा।",
    "राम राम महाबाहो श्रृणु गुह्मं सनातनम्‌।",
    "येन सर्वानरीन्‌ वत्स समरे विजयिष्यसे।",
    "आदित्यहृदयं पुण्यं सर्वशत्रुविनाशनम्‌।",
    "जयावहं जपं नित्यमक्षयं परमं शिवम्‌।",
    "सर्वमंगलमागल्यं सर्वपापप्रणाशनम्‌।",
    "चिन्ताशोकप्रशमनमायुर्वर्धनमुत्तमम्‌।",
    "रश्मिमन्तं समुद्यन्तं देवासुरनमस्कृतम्‌।",
    "पुजयस्व विवस्वन्तं भास्करं भुवनेश्वरम्‌।",
    "सर्वदेवात्मको ह्येष तेजस्वी रश्मिभावन:।",
    "एष देवासुरगणांल्लोकान्‌ पाति गभस्तिभि:।",
    "एष ब्रह्मा च विष्णुश्च शिव: स्कन्द: प्रजापति:।",
    "महेन्द्रो धनद: कालो यम: सोमो ह्यापां पतिः।",
    "पितरो वसव: साध्या अश्विनौ मरुतो मनु:।",
    "वायुर्वहिन: प्रजा प्राण ऋतुकर्ता प्रभाकर:।",
    "आदित्य: सविता सूर्य: खग: पूषा गभस्तिमान्‌।",
    "सुवर्णसदृशो भानुर्हिरण्यरेता दिवाकर:।",
    "हरिदश्व: सहस्त्रार्चि: सप्तसप्तिर्मरीचिमान्‌।",
    "तिमिरोन्मथन: शम्भुस्त्वष्टा मार्तण्डकोंऽशुमान्‌।",
    "हिरण्यगर्भ: शिशिरस्तपनोऽहस्करो रवि:।",
    "अग्निगर्भोऽदिते: पुत्रः शंखः शिशिरनाशन:।",
    "व्योमनाथस्तमोभेदी ऋग्यजु:सामपारग:।",
    "घनवृष्टिरपां मित्रो विन्ध्यवीथीप्लवंगमः।",
    "आतपी मण्डली मृत्यु: पिगंल: सर्वतापन:।",
    "कविर्विश्वो महातेजा: रक्त:सर्वभवोद् भव:।",
    "नक्षत्रग्रहताराणामधिपो विश्वभावन:।",
    "तेजसामपि तेजस्वी द्वादशात्मन्‌ नमोऽस्तु ते।",
    "नम: पूर्वाय गिरये पश्चिमायाद्रये नम:।",
    "ज्योतिर्गणानां पतये दिनाधिपतये नम:।",
    "जयाय जयभद्राय हर्यश्वाय नमो नम:।",
    "नमो नम: सहस्त्रांशो आदित्याय नमो नम:।",
    "नम उग्राय वीराय सारंगाय नमो नम:।",
    "नम: पद्मप्रबोधाय प्रचण्डाय नमोऽस्तु ते।",
    "ब्रह्मेशानाच्युतेशाय सुरायादित्यवर्चसे।",
    "भास्वते सर्वभक्षाय रौद्राय वपुषे नम:।",
    "तमोघ्नाय हिमघ्नाय शत्रुघ्नायामितात्मने।",
    "कृतघ्नघ्नाय देवाय ज्योतिषां पतये नम:।",
    "तप्तचामीकराभाय हरये विश्वकर्मणे।",
    "नमस्तमोऽभिनिघ्नाय रुचये लोकसाक्षिणे।",
    "नाशयत्येष वै भूतं तमेष सृजति प्रभु:।",
    "पायत्येष तपत्येष वर्षत्येष गभस्तिभि:।",
    "एष सुप्तेषु जागर्ति भूतेषु परिनिष्ठित:।",
    "एष चैवाग्निहोत्रं च फलं चैवाग्निहोत्रिणाम्‌।",
    "देवाश्च क्रतवश्चैव क्रतुनां फलमेव च।",
    "यानि कृत्यानि लोकेषु सर्वेषु परमं प्रभु:।",
    "एनमापत्सु कृच्छ्रेषु कान्तारेषु भयेषु च।",
    "कीर्तयन्‌ पुरुष: कश्चिन्नावसीदति राघव।",
    "पूजयस्वैनमेकाग्रो देवदेवं जगप्ततिम्‌।",
    "एतत्त्रिगुणितं जप्त्वा युद्धेषु विजयिष्यसि।",
    "अस्मिन्‌ क्षणे महाबाहो रावणं त्वं जहिष्यसि।",
    "एवमुक्ता ततोऽगस्त्यो जगाम स यथागतम्‌।",
    "एतच्छ्रुत्वा महातेजा नष्टशोकोऽभवत्‌ तदा।",
    "धारयामास सुप्रीतो राघव प्रयतात्मवान्‌।",
    "आदित्यं प्रेक्ष्य जप्त्वेदं परं हर्षमवाप्तवान्‌।",
    "त्रिराचम्य शूचिर्भूत्वा धनुरादाय वीर्यवान्‌।",
    "रावणं प्रेक्ष्य हृष्टात्मा जयार्थं समुपागतम्‌।",
    "सर्वयत्नेन महता वृतस्तस्य वधेऽभवत्‌।",
    "अथ रविरवदन्निरीक्ष्य रामं मुदितमना: परमं प्रहृष्यमाण:।",
    "निशिचरपतिसंक्षयं विदित्वा सुरगणमध्यगतो वचस्त्वरेति।"
  ];


  // English verses
  final List<String> _englishHanumanChalisaVerses = [
    "Shri Guru Charan Saroj raj, Nij manu mukur sudhari",
    "Baranau Raghuvar bimal jasu, Jo dayaku phal chari",
    "Buddhiheen Tanu janike, Sumirau Pavan Kumar",
    "Bal budhi vidya dehu mohi, Harahu kalesh vikaar",

    "Jai Hanuman gyan gun sagar",
    "Jai Kapis tihun lok ujagar",
    "Ram doot atulit bal dhama",
    "Anjani putra Pavan sut nama",

    "Mahabir vikram Bajrangi",
    "Kumati nivar sumati Ke sangi",
    "Kanchan varan viraj subesa",
    "Kanan Kundal Kunchit Kesha",

    "Hath Vajra Aur Dhwaja Viraje",
    "Kandhe moonj janeu saaje",
    "Sankar suvan kesri Nandan",
    "Tej prataap maha jag vandan",

    "Vidyavan guni ati chatur",
    "Ram kaj karibe ko aatur",
    "Prabhu charitra sunibe ko rasiya",
    "Ram Lakhan Sita man basiya",

    "Sukshma roop dhari Siyahi dikhawa",
    "Vikat roop dhari Lanka jalawa",
    "Bhim roop dhari asur sanghare",
    "Ramachandra ke kaj savare",

    "Laye Sanjeevan Lakhan Jiyaye",
    "Shri Raghuvir Harashi ur laye",
    "Raghupati kinhi bahut badai",
    "Tum mam priya Bharat hi sam bhai",

    "Sahas badan tumharo yash gaave",
    "Asa-kahi Shripati kanth lagaave",
    "Sanakadik Brahmadi Muneesha",
    "Narad Sarad sahit Aheesha",

    "Yam Kuber Digpal jahan te",
    "Kavi ko vid kahi sake kahan te",
    "Tum upkar Sugrivahi keenha",
    "Ram milaye rajpad deenha"
  ];


  final List<String> _englishAdityaMantraVerses = [
    "Om Asya Aditya Hridaya Stotrasya Agastya Rishi: Anushtup Chandah",
    "Aditya Hridaya Bhuto Bhagwan Brahma Devata Nirasta Shesha Vighnataya",
    "Brahmavidya Siddhau Sarvatra Jayasiddhau Cha Viniyogah.",
    "Tato Yuddha Parishrantam Samare Chintaya Sthitam.",
    "Ravanam Chagrato Drishtva Yuddhaya Samupasthitam.",
    "Daivataishcha Samagamya Drashtum Abhyagato Ranam.",
    "Upagamyabravid Ramam Agastyo Bhagawant Tada.",
    "Ram Ram Mahabaho Shrinu Guhyam Sanatanam.",
    "Yena Sarvan Arin Vatsa Samare Vijayishyase.",
    "Aditya Hridayam Punyam Sarva Shatru Vinashanam.",
    "Jayavaham Japam Nityam Akshayam Paramam Shivam.",
    "Sarva Mangala Mangalya Sarva Papa Pranashanam.",
    "Chinta Shoka Prashamanam Ayur Vardhanam Uttamam.",

    "Shri Guru Charan Saroj raj Nija manu Mukura sudhari",
    "Baranau Raghuvar Bimal Jasu Jo Dayaku Phala Chari",
    "Budheeheen Tanu Jannike Sumiro Pavan Kumara",
    "Bal Buddhi Vidya Dehoo Mohee Harahu Kalesh Vikaar",
    "Jai Hanuman gyan gun sagar",
    "Jai Kapis tihun lok ujagar",
    "Ram doot atulit bal dhama",
    "Anjani putra Pavan sut nama",
    "Mahabir vikram Bajrangi",
    "Kumati nivar sumati Ke sangi",
    "Kanchan varan viraj subesa",
    "Kanan Kundal Kunchit Kesha",
    "Hath Vajra Aur Dhwaja Viraje",
    "Kaandhe moonj janeu saaje",
    "Sankar suvan kesri Nandan",
    "Tej prataap maha jag vandan"
  ];

  // Kannada verses
  final List<String> _kannadaHanumanChalisaVerses =[
    "ಶ್ರೀ ಗುರು ಚರಣ ಸರೋಜ ರಜ ನಿಜಮನ ಮುಕುರ ಸುಧಾರಿ ।",
    "ವರಣೌ ರಘುವರ ವಿಮಲಯಶ ಜೋ ದಾಯಕ ಫಲಚಾರಿ ॥",
    "ಬುದ್ಧಿಹೀನ ತನುಜಾನಿಕೈ ಸುಮಿರೌ ಪವನ ಕುಮಾರ ।",
    "ಬಲ ಬುದ್ಧಿ ವಿದ್ಯಾ ದೇಹು ಮೋಹಿ ಹರಹು ಕಲೇಶ ವಿಕಾರ ॥",

    "ಅತುಲಿತ ಬಲಧಾಮಂ ಸ್ವರ್ಣ ಶೈಲಾಭ ದೇಹಮ್ ।",
    "ದನುಜ ವನ ಕೃಶಾನುಂ ಜ್ಞಾನಿನಾ ಮಗ್ರಗಣ್ಯಮ್ ॥",
    "ಸಕಲ ಗುಣ ನಿಧಾನಂ ವಾನರಾಣಾ ಮಧೀಶಮ್ ।",
    "ರಘುಪತಿ ಪ್ರಿಯ ಭಕ್ತಂ ವಾತಜಾತಂ ನಮಾಮಿ ॥",

    "ಗೋಷ್ಪದೀಕೃತ ವಾರಾಶಿಂ ಮಶಕೀಕೃತ ರಾಕ್ಷಸಮ್ ।",
    "ರಾಮಾಯಣ ಮಹಾಮಾಲಾ ರತ್ನಂ ವಂದೇ-(ಅ)ನಿಲಾತ್ಮಜಮ್ ॥",
    "ಯತ್ರ ಯತ್ರ ರಘುನಾಥ ಕೀರ್ತನಂ ತತ್ರ ತತ್ರ ಕೃತಮಸ್ತಕಾಂಜಲಿಮ್ ।",
    "ಭಾಷ್ಪವಾರಿ ಪರಿಪೂರ್ಣ ಲೋಚನಂ ಮಾರುತಿಂ ನಮತ ರಾಕ್ಷಸಾಂತಕಮ್ ॥",

    "ಮನೋಜವಂ ಮಾರುತ ತುಲ್ಯವೇಗಮ್ ।",
    "ಜಿತೇಂದ್ರಿಯಂ ಬುದ್ಧಿ ಮತಾಂ ವರಿಷ್ಟಮ್ ॥",
    "ವಾತಾತ್ಮಜಂ ವಾನರಯೂಥ ಮುಖ್ಯಮ್ ।",
    "ಶ್ರೀ ರಾಮ ದೂತಂ ಶಿರಸಾ ನಮಾಮಿ ॥",


    "ಜಯ ಹನುಮಾನ ಜ್ಞಾನ ಗುಣ ಸಾಗರ ।",
    "ಜಯ ಕಪೀಶ ತಿಹು ಲೋಕ ಉಜಾಗರ ॥",
    "ರಾಮದೂತ ಅತುಲಿತ ಬಲಧಾಮಾ ।",
    "ಅಂಜನಿ ಪುತ್ರ ಪವನಸುತ ನಾಮಾ ॥",
    "ಮಹಾವೀರ ವಿಕ್ರಮ ಬಜರಂಗೀ ।",
    "ಕುಮತಿ ನಿವಾರ ಸುಮತಿ ಕೇ ಸಂಗೀ ॥",
    "ಕಂಚನ ವರಣ ವಿರಾಜ ಸುವೇಶಾ ।",
    "ಕಾನನ ಕುಂಡಲ ಕುಂಚಿತ ಕೇಶಾ ॥",
    "ಹಾಥವಜ್ರ ಔ ಧ್ವಜಾ ವಿರಾಜೈ ।",
    "ಕಾಂಥೇ ಮೂಂಜ ಜನೇವೂ ಸಾಜೈ ॥",
    "ಶಂಕರ ಸುವನ ಕೇಸರೀ ನಂದನ ।",
    "ತೇಜ ಪ್ರತಾಪ ಮಹಾಜಗ ವಂದನ ॥"
  ];

  final List<String> _kannadaAdityaMantraVerses =[

    "ಶ್ರೀ ಗುರು ಚರಣ ಸರೋಜ ರಜ ನಿಜಮನ ಮುಕುರ ಸುಧಾರಿ ।",
    "ವರಣೌ ರಘುವರ ವಿಮಲಯಶ ಜೋ ದಾಯಕ ಫಲಚಾರಿ ॥",
    "ಬುದ್ಧಿಹೀನ ತನುಜಾನಿಕೈ ಸುಮಿರೌ ಪವನ ಕುಮಾರ ।",
    "ಬಲ ಬುದ್ಧಿ ವಿದ್ಯಾ ದೇಹು ಮೋಹಿ ಹರಹು ಕಲೇಶ ವಿಕಾರ ॥",


    "ನಮಸ್ಸವಿತ್ರೇ ಜಗದೇಕ ಚಕ್ಷುಸೇ",
    "ಜಗತ್ಪ್ರಸೂತಿ ಸ್ಥಿತಿ ನಾಶಹೇತವೇ",
    "ತ್ರಯೀಮಯಾಯ ತ್ರಿಗುಣಾತ್ಮ ಧಾರಿಣೇ",
    "ವಿರಿಂಚಿ ನಾರಾಯಣ ಶಂಕರಾತ್ಮನೇ",

    "ತತೋ ಯುದ್ಧ ಪರಿಶ್ರಾಂತಂ ಸಮರೇ ಚಿಂತಯಾಸ್ಥಿತಮ್ ।",
    "ರಾವಣಂ ಚಾಗ್ರತೋ ದೃಷ್ಟ್ವಾ ಯುದ್ಧಾಯ ಸಮುಪಸ್ಥಿತಮ್ ॥",
    "ದೈವತೈಶ್ಚ ಸಮಾಗಮ್ಯ ದ್ರಷ್ಟುಮಭ್ಯಾಗತೋ ರಣಮ್ ।",
    "ಉಪಾಗಮ್ಯಾಬ್ರವೀದ್ರಾಮಂ ಅಗಸ್ತ್ಯೋ ಭಗವಾನ್ ಋಷಿಃ ॥",

    "ರಾಮ ರಾಮ ಮಹಾಬಾಹೋ ಶೃಣು ಗುಹ್ಯಂ ಸನಾತನಮ್ ।",
    "ಯೇನ ಸರ್ವಾನರೀನ್ ವತ್ಸ ಸಮರೇ ವಿಜಯಿಷ್ಯಸಿ ॥",
    "ಆದಿತ್ಯಹೃದಯಂ ಪುಣ್ಯಂ ಸರ್ವಶತ್ರು-ವಿನಾಶನಮ್ ।",
    "ಜಯಾವಹಂ ಜಪೇನ್ನಿತ್ಯಂ ಅಕ್ಷಯ್ಯಂ ಪರಮಂ ಶಿವಮ್ ॥",

    "ಸರ್ವಮಂಗಳ-ಮಾಂಗಳ್ಯಂ ಸರ್ವಪಾಪ-ಪ್ರಣಾಶನಮ್ ।",
    "ಚಿಂತಾಶೋಕ-ಪ್ರಶಮನಂ ಆಯುರ್ವರ್ಧನಮುತ್ತಮಮ್ ॥",
    "ರಶ್ಮಿಮಂತಂ ಸಮುದ್ಯಂತಂ ದೇವಾಸುರ ನಮಸ್ಕೃತಮ್ ।",
    "ಪೂಜಯಸ್ವ ವಿವಸ್ವಂತಂ ಭಾಸ್ಕರಂ ಭುವನೇಶ್ವರಮ್ ॥",

    "ಸರ್ವದೇವಾತ್ಮಕೋ ಹ್ಯೇಷ ತೇಜಸ್ವೀ ರಶ್ಮಿಭಾವನಃ ।",
    "ಏಷ ದೇವಾಸುರ-ಗಣಾನ್ ಲೋಕಾನ್ ಪಾತಿ ಗಭಸ್ತಿಭಿಃ ॥",
    "ಏಷ ಬ್ರಹ್ಮಾ ಚ ವಿಷ್ಣುಶ್ಚ ಶಿವಃ ಸ್ಕಂದಃ ಪ್ರಜಾಪತಿಃ ।",
    "ಮಹೇಂದ್ರೋ ಧನದಃ ಕಾಲೋ ಯಮಃ ಸೋಮೋ ಹ್ಯಪಾಂ ಪತಿಃ ॥"
  ];


  //bool showAdityaMantra = false;
  @override
  void initState() {
    super.initState();

    // Update these asset paths to your audio files.
    _inhaleSound = AssetSource('../assets/music/inhale_bell1.mp3');
    _exhaleSound = AssetSource('../assets/music/exhale_bell1.mp3');
    _mantraSound = AssetSource('../assets/music/mantra.mp4');

    _totalDuration = (widget.inhaleDuration +
        widget.hold1Duration +
        widget.exhaleDuration +
        widget.hold2Duration)
        .toDouble();
    _f1 = widget.inhaleDuration / _totalDuration;
    _f2 = (widget.inhaleDuration + widget.hold1Duration) / _totalDuration;
    _f3 =
        (widget.inhaleDuration + widget.hold1Duration + widget.exhaleDuration) /
            _totalDuration;

    _inhalePlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop);
    _exhalePlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop);
    _chalisaPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);     // Add this with loop mode
    _adityaMantraPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);// Loop the mantra background music
    _preloadAudio();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalDuration.toInt()),
    );

    // Create pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);
  }

  Future<void> _preloadAudio() async {
    try {
      await Future.wait([
        _inhalePlayer.setSource(_inhaleSound),
        _exhalePlayer.setSource(_exhaleSound),
        _chalisaPlayer.setSource(AssetSource('../assets/music/chalisaaudio.mp3')),
        _adityaMantraPlayer.setSource(AssetSource('../assets/music/adi.mp3')),
      ]);
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  void _handleAnimationProgress() {
    double progress = _controller.value;
    String newPhase;
    String newActiveSide;

    // Determine current phase and side
    if (progress < _f1) {
      newPhase = "Inhale";
      newActiveSide = "top";
    } else if (progress < _f2) {
      newPhase = "Hold";
      newActiveSide = "right";
    } else if (progress < _f3) {
      newPhase = "Exhale";
      newActiveSide = "bottom";
    } else {
      newPhase = "Hold";
      newActiveSide = "left";
    }

    // If we changed sides
    if (newActiveSide != _activeSide) {
      setState(() {
        _activeSide = newActiveSide;
      });
    }

    // If we changed phase
    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      if (isAudioPlaying) {
        _playPhaseSound(newPhase);
      }

      setState(() {
        breathingText = newPhase;
      });
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      // When one cycle completes, reset all side statuses
      _resetSideReadStatus();

      // Move to next group of 4 verses
      if (showHanumanChalisa || showAdityaMantra) {
        setState(() {
          List<String> currentVerses = _getCurrentVerses();

          _currentVerseIndex = (_currentVerseIndex + 4) % currentVerses.length;
          // Make sure we don't go past the end of the list
          if (_currentVerseIndex + 3 >= currentVerses.length) {
            _currentVerseIndex = 0;
          }
        });
      }


      _currentRound++;
      if (_currentRound < widget.rounds) {
        _controller.reset();
        await Future.delayed(const Duration(milliseconds: 500));
        if (isRunning) {
          _startBreathingCycle();
        }
      } else {
        setState(() {
          isRunning = false;
          breathingText = "Complete";
        });
        await _stopAllAudio();
      }
    }
  }

  List<String> _getCurrentVerses() {
    if (showAdityaMantra) {
      // For Aditya Mantra
      switch (_selectedLanguage) {
        case "English":
          return _englishAdityaMantraVerses;
        case "Kannada":
          return _kannadaAdityaMantraVerses;
        default: // Sanskrit
          return _adityaMantraVerses;
      }
    } else {
      // For Hanuman Chalisa
      switch (_selectedLanguage) {
        case "English":
          return _englishHanumanChalisaVerses;
        case "Kannada":
          return _kannadaHanumanChalisaVerses;
        default: // Sanskrit
          return _hanumanChalisaVerses;
      }
    }
  }

  void _resetSideReadStatus() {
    _sideRead = {
      "top": false,
      "right": false,
      "bottom": false,
      "left": false,
    };
  }

  Future<void> _playPhaseSound(String phase) async {
    try {
      if (phase == "Inhale") {
        await _exhalePlayer.stop();
        await _inhalePlayer.resume();
      } else if (phase == "Exhale") {
        await _inhalePlayer.stop();
        await _exhalePlayer.resume();
      } else {
        await _inhalePlayer.stop();
        await _exhalePlayer.stop();
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _startBreathingCycle() {
    setState(() {
      breathingText = "Inhale";
      _currentPhase = "Inhale";
      _activeSide = "top";
      _resetSideReadStatus();
    });
    _controller.forward();
    if (isAudioPlaying) {
      _playPhaseSound("Inhale");
    }
  }

  Future<void> toggleBreathing() async {
    if (isRunning) {
      _controller.stop();
      await _stopAllAudio();
      setState(() {
        isRunning = false;
      });
    } else {
      if (_currentRound >= widget.rounds) {
        _currentRound = 0;
        _currentVerseIndex = 0;
      }
      setState(() {
        isRunning = true;
      });
      _startBreathingCycle();
    }
  }

  Future<void> _stopAllAudio() async {
    await Future.wait([
      _inhalePlayer.stop(),
      _exhalePlayer.stop(),
      _chalisaPlayer.stop(),       // Add this
      _adityaMantraPlayer.stop(),
    ]);
  }

  Future<void> toggleAudio() async {
    final newVolume = isAudioPlaying ? 0.0 : 1.0;
    await Future.wait([
      _inhalePlayer.setVolume(newVolume),
      _exhalePlayer.setVolume(newVolume),
      _chalisaPlayer.setVolume(newVolume),        // Add this
      _adityaMantraPlayer.setVolume(newVolume),
    ]);
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
  }

  void toggleHanumanChalisa() {
    setState(() {
      if (showHanumanChalisa) {
        // If Hanuman Chalisa is showing, turn it off
        showHanumanChalisa = false;
        _chalisaPlayer.stop();
      } else {
        // Turn on Hanuman Chalisa and ensure Aditya Mantra is off
        showHanumanChalisa = true;
        showAdityaMantra = false;
        _adityaMantraPlayer.stop(); // Stop Aditya Mantra audio
        _chalisaPlayer.resume();
      }
      _currentVerseIndex = 0;
      _resetSideReadStatus();
    });
  }

  void toggleAdityaMantra() {
    setState(() {
      if (showAdityaMantra) {
        // If Aditya Mantra is showing, turn it off
        showAdityaMantra = false;
        _adityaMantraPlayer.stop();
      } else {
        // Turn on Aditya Mantra and ensure Hanuman Chalisa is off
        showAdityaMantra = true;
        showHanumanChalisa = false;
        _chalisaPlayer.stop(); // Stop Hanuman Chalisa audio
        _adityaMantraPlayer.resume();
      }
      _currentVerseIndex = 0;
      _resetSideReadStatus();
    });
  }

  // Set the selected language
  void _setLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
      _currentVerseIndex = 0;
      _resetSideReadStatus();
    });
  }

  // Mark the current side as read
  void markSideAsRead(String side) {
    if ((showHanumanChalisa || showAdityaMantra) && side == _activeSide &&
        !_sideRead[side]!) {
      setState(() {
        _sideRead[side] = true;
      });
    }
  }

  /// Gets the index for the verse based on the side
  int _getVerseIndexForSide(String side) {
    int index;
    switch (side) {
      case "top":
        index = _currentVerseIndex;
        break;
      case "right":
        index = _currentVerseIndex + 1;
        break;
      case "bottom":
        index = _currentVerseIndex + 2;
        break;
      case "left":
        index = _currentVerseIndex + 3;
        break;
      default:
        index = _currentVerseIndex;
    }

    List<String> currentVerses = _getCurrentVerses();

    // Make sure we don't go out of bounds
    return index % currentVerses.length;
  }

  /// Computes the center of the moving ball along the square's perimeter.
  Offset _calculateCirclePosition(double t, double size) {
    if (t < _f1) {
      // Inhale: from A to B
      double fraction = t / _f1;
      double x = fraction * size;
      double y = 0;
      return Offset(x, y);
    } else if (t < _f2) {
      // Hold: from B to C
      double fraction = (t - _f1) / (_f2 - _f1);
      double x = size;
      double y = fraction * size;
      return Offset(x, y);
    } else if (t < _f3) {
      // Exhale: from C to D
      double fraction = (t - _f2) / (_f3 - _f2);
      double x = size * (1 - fraction);
      double y = size;
      return Offset(x, y);
    } else {
      // Hold: from D to A
      double fraction = (t - _f3) / (1 - _f3);
      double x = 0;
      double y = size * (1 - fraction);
      return Offset(x, y);
    }
  }

  /// Create a text widget for a verse with proper styling and rotation
  Widget _buildVerseWidget(String side, bool isActive) {
    int verseIndex = _getVerseIndexForSide(side);

    // Get the current verses based on language and type selection
    List<String> currentVerses = _getCurrentVerses();

    // Handle potential index out of bounds
    if (verseIndex >= currentVerses.length) {
      verseIndex = currentVerses.length - 1;
    }

    String verse = currentVerses.isNotEmpty ? currentVerses[verseIndex] : "";
    bool isRead = _sideRead[side]!;

    // Define colors for different states
    Color textColor = isActive
        ? isRead ? Color(0xFF4CAF50) : Color(0xFFFFAB40)
        : Colors.grey[400]!;

    Color bgColor = isActive
        ? isRead ? Color(0xFF4CAF50).withOpacity(0.15) : Color(0xFFFFAB40)
        .withOpacity(0.15)
        : Colors.transparent;

    Color borderColor = isActive
        ? isRead ? Color(0xFF4CAF50) : Color(0xFFFFAB40)
        : Colors.transparent;

    FontWeight fontWeight = isActive ? FontWeight.bold : FontWeight.normal;
    double fontSize = isActive ? 16.0 : 14.0;

    Widget textWidget = Text(
      verse,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    // Rotate text for left and right sides
    if (side == "left") {
      textWidget = RotatedBox(
        quarterTurns: 3,
        child: textWidget,
      );
    } else if (side == "right") {
      textWidget = RotatedBox(
        quarterTurns: 1,
        child: textWidget,
      );
    }

    return GestureDetector(
      onTap: () => isActive ? markSideAsRead(side) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isActive ? [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ] : null,
        ),
        child: textWidget,
      ),
    );
  }

  /// Builds the box with the moving ball and side-specific karaoke verses
  Widget _buildBoxAnimation() {
    const double boxSize = 300;
    const double ballDiameter = 24;
    const double ballRadius = ballDiameter / 2;
    const double textPadding = 40.0;

    return Container(
      width: boxSize + (textPadding * 2),
      height: boxSize + (textPadding * 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background glow
          Positioned(
            left: textPadding,
            top: textPadding,
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2E7D32).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),

          // The main box with gradient border
          Positioned(
            left: textPadding,
            top: textPadding,
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent, width: 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                painter: GradientBoxPainter(),
                size: Size(boxSize, boxSize),
              ),
            ),
          ),

          // Only show verses if Hanuman Chalisa OR Aditya Mantra is enabled
          if (showHanumanChalisa || showAdityaMantra) ...[
            // Top verse - enough space from the box
            Positioned(
              top: 0,
              left: textPadding + 20,
              right: textPadding + 20,
              child: _buildVerseWidget("top", _activeSide == "top"),
            ),

            // Right verse - enough space from the box
            Positioned(
              right: 0,
              top: textPadding + 20,
              bottom: textPadding + 20,
              width: textPadding * 2,
              child: _buildVerseWidget("right", _activeSide == "right"),
            ),

            // Bottom verse - enough space from the box
            Positioned(
              bottom: 0,
              left: textPadding + 20,
              right: textPadding + 20,
              child: _buildVerseWidget("bottom", _activeSide == "bottom"),
            ),

            // Left verse - enough space from the box
            Positioned(
              left: 0,
              top: textPadding + 20,
              bottom: textPadding + 20,
              width: textPadding * 2,
              child: _buildVerseWidget("left", _activeSide == "left"),
            ),
          ],

          // The moving ball with pulse effect
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              Offset circleCenter = _calculateCirclePosition(
                  _controller.value, boxSize);

              // Customize ball appearance based on the current phase
              Color ballColor;
              Color glowColor;

              if (_currentPhase == "Inhale") {
                ballColor = Color(0xFF1E88E5); // Blue for inhale
                glowColor = Color(0xFF1E88E5).withOpacity(0.5);
              } else if (_currentPhase == "Exhale") {
                ballColor = Color(0xFFE57373); // Red for exhale
                glowColor = Color(0xFFE57373).withOpacity(0.5);
              } else { // Hold phases
                ballColor = Color(0xFFFFB74D); // Orange for hold
                glowColor = Color(0xFFFFB74D).withOpacity(0.5);
              }

              return Positioned(
                left: textPadding + circleCenter.dx - ballRadius,
                top: textPadding + circleCenter.dy - ballRadius,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                      begin: 1.0, end: _currentPhase == "Hold" ? 1.0 : 1.2),
                  duration: Duration(
                      milliseconds: _currentPhase == "Hold" ? 0 : 1000),
                  builder: (context, value, child) {
                    return Container(
                      width: ballDiameter *
                          (_currentPhase == "Inhale" ? value : 1.0),
                      height: ballDiameter *
                          (_currentPhase == "Inhale" ? value : 1.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ballColor,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: ballDiameter * 0.5,
                          height: ballDiameter * 0.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the control buttons (Start/Pause/Repeat).
  Widget _buildControlButtons() {
    if (_currentRound >= widget.rounds) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _currentRound = 0;
            _currentVerseIndex = 0;
            isRunning = true;
            _resetSideReadStatus();
          });
          _controller.reset();
          _startBreathingCycle();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00796B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          shadowColor: Color(0xFF00796B).withOpacity(0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 22),
            SizedBox(width: 8),
            Text(
              "Repeat",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: toggleBreathing,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? Color(0xFFE57373) : Color(0xFF66BB6A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          shadowColor: (isRunning ? Color(0xFFE57373) : Color(0xFF66BB6A))
              .withOpacity(0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 22),
            SizedBox(width: 8),
            Text(
              isRunning ? "Pause" : "Start",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Builds the audio toggle button
  Widget _buildAudioToggle() {
    return InkWell(
      onTap: toggleAudio,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF263238).withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          isAudioPlaying ? Icons.volume_up : Icons.volume_off,
          color: isAudioPlaying ? Color(0xFF4CAF50) : Colors.grey,
          size: 30,
        ),
      ),
    );
  }

  /// Builds the Hanuman Chalisa toggle button
  Widget _buildHanumanChalisaToggle() {
    return ElevatedButton.icon(
      onPressed: toggleHanumanChalisa,
      style: ElevatedButton.styleFrom(
        backgroundColor: showHanumanChalisa ? Color(0xFFFF9800) : Color(
            0xFF607D8B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: (showHanumanChalisa ? Color(0xFFFF9800) : Color(
            0xFF607D8B)).withOpacity(0.5),
      ),
      icon: Icon(
        Icons.menu_book,
        size: 20,
      ),
      label: Text(
        "Hanuman Chalisa",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAdityaMantraToggle() {
    return ElevatedButton.icon(
      onPressed: toggleAdityaMantra,
      style: ElevatedButton.styleFrom(
        backgroundColor: showAdityaMantra ? Color(0xFFFF5722) : Color(
            0xFF607D8B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: (showAdityaMantra ? Color(0xFFFF5722) : Color(0xFF607D8B))
            .withOpacity(0.5),
      ),
      icon: Icon(
        Icons.wb_sunny,
        size: 20,
      ),
      label: Text(
        "Aditya Mantra",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds language selection buttons
  Widget _buildLanguageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLanguageButton("Sanskrit", Color(0xFF9C27B0)),
        SizedBox(width: 12),
        _buildLanguageButton("English", Color(0xFF1976D2)),
        SizedBox(width: 12),
        _buildLanguageButton("Kannada", Color(0xFF388E3C)),
      ],
    );
  }

  /// Creates an individual language selection button
  Widget _buildLanguageButton(String language, Color color) {
    bool isSelected = _selectedLanguage == language;

    return ElevatedButton(
      onPressed: () => _setLanguage(language),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Color(0xFF455A64),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 8 : 4,
        shadowColor: isSelected ? color.withOpacity(0.5) : Colors.black
            .withOpacity(0.2),
      ),
      child: Text(
        language,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds the breathing phase display
  Widget _buildBreathingPhaseText() {
    Color textColor;

    // Different colors for different phases
    switch (_currentPhase) {
      case "Inhale":
        textColor = Color(0xFF1E88E5); // Blue
        break;
      case "Exhale":
        textColor = Color(0xFFE57373); // Red
        break;
      case "Hold":
        textColor = Color(0xFFFFB74D); // Orange
        break;
      default:
        textColor = Colors.white;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(
            breathingText,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 5,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the rounds progress indicator
  Widget _buildRoundsIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF263238).withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            "Round ${_currentRound < widget.rounds ? _currentRound + 1 : widget
                .rounds} of ${widget.rounds}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the verses progress indicator
  Widget _buildVersesProgressIndicator() {
    // Only show if either text is active
    bool showIndicator = showHanumanChalisa || showAdityaMantra;

    // Choose the right icon, color, and text based on which text is active
    IconData indicatorIcon = showAdityaMantra ? Icons.wb_sunny : Icons
        .auto_stories;
    Color indicatorColor = showAdityaMantra ? Color(0xFFFF5722) : Color(
        0xFFFF9800);
    List<String> currentVerses = showAdityaMantra
        ? _adityaMantraVerses
        : _hanumanChalisaVerses;
    String textType = showAdityaMantra ? "Mantras" : "Verses";

    return AnimatedOpacity(
      opacity: showIndicator ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: indicatorColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: indicatorColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              indicatorIcon,
              color: indicatorColor,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              "$textType ${_currentVerseIndex + 1}-${min(_currentVerseIndex + 4,
                  currentVerses.length)} of ${currentVerses.length}",
              style: TextStyle(
                color: indicatorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inhalePlayer.dispose();
    _exhalePlayer.dispose();
    _chalisaPlayer.dispose();       // Add this
    _adityaMantraPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Box Breathing",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildAudioToggle(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF263238),
              Color(0xFF1A2327),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Breathing phase text with animation
                    _buildBreathingPhaseText(),
                    SizedBox(height: 30),

                    // The animated box
                    _buildBoxAnimation(),
                    SizedBox(height: 25),

                    // Progress indicators
                    _buildVersesProgressIndicator(),
                    SizedBox(height: 16),
                    _buildRoundsIndicator(),
                    SizedBox(height: 35),

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButtons(),
                        SizedBox(width: 16),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHanumanChalisaToggle(),
                        SizedBox(width: 16),
                        _buildAdityaMantraToggle(),
                      ],
                    ),

                    // Language selection buttons - Added here
                    SizedBox(height: 20),
                    Visibility(
                      visible: showHanumanChalisa || showAdityaMantra,
                      child: Column(
                        children: [
                          Text(
                            "Select Language",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildLanguageButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for a gradient border
class GradientBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(12));

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF00BFA5),
        Color(0xFF1976D2),
        Color(0xFF9C27B0),
        Color(0xFFFF5722),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRRect(rrect, paint);

    // Draw subtle inner glow
    final innerGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(4),
        Radius.circular(8),
      ),
      innerGlowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Animated background for a more immersive experience
class AnimatedBackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  AnimatedBackgroundPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value;

    // Create multiple layers of subtle patterns
    for (int i = 0; i < 3; i++) {
      final offset = 120.0 * i;
      final opacity = 0.05 - (i * 0.01);
      final speed = 0.2 + (i * 0.1);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int j = 0; j < 5; j++) {
        final radius = 50.0 + (j * 30) + (sin(time * speed + j) * 10);
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
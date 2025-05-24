import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;
import 'dart:math';

class BoxBreathingScreen extends StatefulWidget {
  final int inhaleDuration;
  final int hold1Duration;
  final int exhaleDuration;
  final int hold2Duration;
  final int rounds;
  final String mantra;

  const BoxBreathingScreen({
    Key? key,
    required this.inhaleDuration,
    required this.hold1Duration,
    required this.exhaleDuration,
    required this.hold2Duration,
    required this.rounds,
    required this.mantra,
  }) : super(key: key);

  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _inhalePlayer;
  late AudioPlayer _exhalePlayer;
  late AudioPlayer _chalisaPlayer;
  late AudioPlayer _adityaMantraPlayer;
  bool isRunning = false;
  bool isAudioPlaying = true;
  bool showHanumanChalisa = false;
  bool showAdityaMantra = false;
  String breathingText = "Get Ready";
  int _currentRound = 0;
  String _currentPhase = "";
  int _currentVerseIndex = 0;
  String _selectedLanguage = "Sanskrit";

  Map<String, bool> _sideRead = {
    "top": false,
    "right": false,
    "bottom": false,
    "left": false,
  };
  String _activeSide = "top";

  late final AssetSource _inhaleSound;
  late final AssetSource _exhaleSound;
  late final AssetSource _mantraSound;

  late final double _totalDuration;
  late final double _f1;
  late final double _f2;
  late final double _f3;

  late Animation<double> _pulseAnimation;

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

  final List<String> _adityaMantraVerses = [
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
    "Kumati nivar sumati ke sangi",
    "Kanchan varan viraj subesa",
    "Kanan kundal kunchit kesha",
    "Hath vajra aur dhwaja viraje",
    "Kandhe moonj janeu saaje",
    "Sankar suvan Kesri Nandan",
    "Tej pratap maha jag vandan",
    "Vidyavan guni ati chatur",
    "Ram kaj karibe ko aatur",
    "Prabhu charitra sunibe ko rasiya",
    "Ram Lakhan Sita man basiya",
    "Sukshma roop dhari Siyahi dikhava",
    "Vikat roop dhari Lanka jalava",
    "Bhim roop dhari asur sanghare",
    "Ramachandra ke kaj savare",
    "Laye Sanjeevan Lakhan Jiyaye",
    "Shri Raghuvir Harashi ur laye",
    "Raghupati kinhi bahut badai",
    "Tum mam priya Bharat hi sam bhai",
    "Sahas badan tumharo yash gaave",
    "Asa kahi Shripati kanth lagaave",
    "Sanakadik Brahmadi Muneesha",
    "Narad Sarad sahit Aheesha",
    "Yam Kuber Digpal jahan te",
    "Kavi kovid kahi sake kahan te",
    "Tum upkar Sugrivahi keenha",
    "Ram milaye rajpad deenha",
    "Tumharo mantra Vibhishan maana",
    "Lankeshwar bhaye sab jag jana",
    "Yug sahastra yojan par Bhanu",
    "Lilyo tahi madhur phal janu",
    "Prabhu mudrika meli mukh mahee",
    "Jaladhi langhi gaye achraj nahee",
    "Durgam kaj jagat ke jete",
    "Sugam anugrah tumhare tete",
    "Ram duare tum rakhvare",
    "Hot na agya binu paisare",
    "Sab sukh lahe tumhari sharan",
    "Tum rakshak kahu ko dar na",
    "Aapan tej samharo aapai",
    "Teenon lok hank te kampai",
    "Bhoot pishach nikat nahi aavai",
    "Mahavir jab naam sunavai",
    "Naasai rog harai sab peera",
    "Japat nirantar Hanumat beera",
    "Sankat se Hanuman chhudavai",
    "Man Kram Vachan dhyan jo lavai",
    "Sab par Ram tapasvee raja",
    "Tin ke kaj sakal tum saja",
    "Aur manorath jo koi lavai",
    "Soi amit jeevan phal pavai",
    "Charon yug pratap tumhara",
    "Hai prasiddha jagat ujiyara",
    "Sadhu sant ke tum rakhware",
    "Asur nikandan Ram dulare",
    "Ashta siddhi nav nidhi ke data",
    "Asa var deen Janaki mata",
    "Ram rasayan tumhare pasa",
    "Sada raho Raghupati ke dasa",
    "Tumhare bhajan Ram ko pavai",
    "Janam janam ke dukh bisravai",
    "Ant kaal Raghupati pur jai",
    "Jahan janam Hari bhakt kahai",
    "Aur devta chitt na dharai",
    "Hanumat sei sarva sukh karai",
    "Sankat kate mite sab peera",
    "Jo sumirai Hanumat balbeera",
    "Jai Jai Jai Hanuman Gosai",
    "Kripa karahu Gurudev ki nai",
    "Jo sat bar path kare koyi",
    "Chhootahi bandi maha sukh hoyi",
    "Jo yeh padhe Hanuman Chalisa",
    "Hoye siddhi Sakhi Gaureesa",
    "Tulsidas sada hari chera",
    "Keejai Nath hriday mah dera",

  ];


  final List<String> _englishAdityaMantraVerses = [
  "ēṣa brahmā cha viṣṇuścha",
  "śivaḥ skandaḥ prajāpatiḥ",
  "mahēndrō dhanadaḥ kālō",
  "yamaḥ sōmō hyapāṃ patiḥ",
  "pitarō vasavaḥ sādhyā",
  "hyaśvinau marutō manuḥ",
  "vāyurvahniḥ prajāprāṇaḥ",
  "ṛtukartā prabhākaraḥ",
  "ādityaḥ savitā sūryaḥ",
  "khagaḥ pūṣā gabhastimān",
  "suvarṇasadṛśō bhānuḥ",
  "hiraṇyarētā divākaraḥ",
  "haridaśvaḥ sahasrārchiḥ",
  "saptasaptiḥ marīchimān",
  "timirōnmathanaḥ śambhuḥ",
  "tvaṣṭā mārtāṇḍakōṃ'śumān",
  "hiraṇyagarbhaḥ śiśiraḥ",
  "tapanō bhāskarō raviḥ",
  "agnigarbhō'ditēḥ putraḥ",
  "śaṅkhaḥ śiśiranāśanaḥ",
  "vyōmanāthaḥ tamōbhēdī",
  "ṛgyajuḥsāma pāragaḥ",
  "ghanāvṛṣṭir apāṃ mitraḥ",
  "vindhyavīthī plavaṅgamaḥ",
  "ātapī maṇḍalī mṛtyuḥ",
  "piṅgaḻaḥ sarvatāpanaḥ",
  "kavirviśvō mahātējāḥ",
  "raktaḥ sarvabhavōdbhavaḥ",
  "nakṣatra graha tārāṇāṃ",
  "adhipō viśvabhāvanaḥ",
  "tējasāmapi tējasvī",
  "dvādaśātman namō'stu tē",
  "namaḥ pūrvāya girayē",
  "paśchimāyādrayē namaḥ",
  "jyōtirgaṇānāṃ patayē",
  "dinādhipatayē namaḥ",
  "jayāya jayabhadrāya",
  "haryaśvāya namō namaḥ",
  "namō namaḥ sahasrāṃśō",
  "ādityāya namō namaḥ",
  "nama ugrāya vīrāya",
  "sāraṅgāya namō namaḥ",
  "namaḥ padmaprabōdhāya",
  "mārtāṇḍāya namō namaḥ",
  "brahmēśānāchyutēśāya",
  "sūryāyāditya varchasē",
  "bhāsvatē sarvabhakṣāya",
  "raudrāya vapuṣē namaḥ",
  "tamōghnāya himaghnāya",
  "śatrughnāyā mitātmanē",
  "kṛtaghnaghnāya dēvāya",
  "jyōtiṣāṃ patayē namaḥ",
  "tapta chāmīkarābhāya",
  "vahnayē viśvakarmaṇē",
  "namastamō'bhini ghnāya",
  "ravayē lōkasākṣiṇē",
  "nāśayatyēṣa vai bhūtaṃ",
  "tadēva sṛjati prabhuḥ",
  "pāyatyēṣa tapatyēṣa",
  "varṣatyēṣa gabhastibhiḥ",
  "ēṣa suptēṣu jāgarti",
  "bhūtēṣu pariniṣṭhitaḥ",
  "ēṣa ēvāgnihōtraṃ cha",
  "phalaṃ chaivāgni hōtriṇām",
  "vēdāścha kratavaśchaiva",
  "kratūnāṃ phalamēva cha",
  "yāni kṛtyāni lōkēṣu",
  "sarva ēṣa raviḥ prabhuḥ",
  "ēna māpatsu kṛchChrēṣu",
  "kāntārēṣu bhayēṣu cha",
  "kīrtayan puruṣaḥ kaśchin",
  "nāvaśīdati rāghava",
  "pūjayasvaina mēkāgraḥ",
  "dēvadēvaṃ jagatpatim",
  "ētat triguṇitaṃ japtvā",
  "yuddhēṣu vijayiṣyasi",
  "asmin kṣaṇē mahābāhō",
  "rāvaṇaṃ tvaṃ vadhiṣyasi",
  "ēvamuktvā tadāgastyō",
  "jagāma cha yathāgatam",
  "ētachChrutvā mahātējāḥ",
  "naṣṭaśōkō'bhavattadā",
  "dhārayāmāsa suprītaḥ",
  "rāghavaḥ prayatātmavān",
  "ādityaṃ prēkṣya japtvā tu",
  "paraṃ harṣamavāptavān",
  "trirāchamya śuchirbhūtvā",
  "dhanurādāya vīryavān",
  "rāvaṇaṃ prēkṣya hṛṣṭātmā",
  "yuddhāya samupāgamat",
  "sarvayatnēna mahatā",
  "vadhē tasya dhṛtō'bhavat",
  "adha raviravadannirīkṣya rāmaṃ",
  "muditamanāḥ paramaṃ prahṛṣyamāṇaḥ",
  "niśicharapati saṅkṣayaṃ viditvā",
  "suragaṇa madhyagatō vachastvarēti"
  ];


  final List<String> _kannadaHanumanChalisaVerses = [
    // Doha (Intro)
    "ಶ್ರೀ ಗುರು ಚರಣ ಸರೋಜ ರಜ ನಿಜಮನ ಮುಕುರ ಸುಧಾರಿ ।",
    "ವರಣೌ ರಘುವರ ವಿಮಲಯಶ ಜೋ ದಾಯಕ ಫಲಚಾರಿ ॥",
    "ಬುದ್ಧಿಹೀನ ತನುಜಾನಿಕೈ ಸುಮಿರೌ ಪವನ ಕುಮಾರ ।",
    "ಬಲ ಬುದ್ಧಿ ವಿದ್ಯಾ ದೇಹು ಮೋಹಿ ಹರಹು ಕಲೇಶ ವಿಕಾರ ॥",


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
    "ತೇಜ ಪ್ರತಾಪ ಮಹಾಜಗ ವಂದನ ॥",
    "ವಿದ್ಯಾವಾನ ಗುಣೀ ಅತಿ ಚಾತುರ ।",
    "ರಾಮ ಕಾಜ ಕರಿವೇ ಕೋ ಆತುರ ॥",
    "ಪ್ರಭು ಚರಿತ್ರ ಸುನಿವೇ ಕೋ ರಸಿಯಾ ।",
    "ರಾಮಲಖನ ಸೀತಾ ಮನ ಬಸಿಯಾ ॥",
    "ಸೂಕ್ಷ್ಮ ರೂಪಧರಿ ಸಿಯಹಿ ದಿಖಾವಾ ।",
    "ವಿಕಟ ರೂಪಧರಿ ಲಂಕ ಜಲಾವಾ ॥",
    "ಭೀಮ ರೂಪಧರಿ ಅಸುರ ಸಂಹಾರೇ ।",
    "ರಾಮಚಂದ್ರ ಕೇ ಕಾಜ ಸಂವಾರೇ ॥",
    "ಲಾಯ ಸಂಜೀವನ ಲಖನ ಜಿಯಾಯೇ ।",
    "ಶ್ರೀ ರಘುವೀರ ಹರಷಿ ಉರಲಾಯೇ ॥",
    "ರಘುಪತಿ ಕೀನ್ಹೀ ಬಹುತ ಬಡಾಯೀ ।",
    "ತುಮ ಮಮ ಪ್ರಿಯ ಭರತ ಸಮ ಭಾಯೀ ॥",
    "ಸಹಸ್ರ ವದನ ತುಮ್ಹರೋ ಯಶಗಾವೈ ।",
    "ಅಸ ಕಹಿ ಶ್ರೀಪತಿ ಕಂಠ ಲಗಾವೈ ॥",
    "ಸನಕಾದಿಕ ಬ್ರಹ್ಮಾದಿ ಮುನೀಶಾ ।",
    "ನಾರದ ಶಾರದ ಸಹಿತ ಅಹೀಶಾ ॥",
    "ಯಮ ಕುಬೇರ ದಿಗಪಾಲ ಜಹಾಂ ತೇ ।",
    "ಕವಿ ಕೋವಿದ ಕಹಿ ಸಕೇ ಕಹಾಂ ತೇ ॥",
    "ತುಮ ಉಪಕಾರ ಸುಗ್ರೀವಹಿ ಕೀನ್ಹಾ ।",
    "ರಾಮ ಮಿಲಾಯ ರಾಜಪದ ದೀನ್ಹಾ ॥",
    "ತುಮ್ಹರೋ ಮಂತ್ರ ವಿಭೀಷಣ ಮಾನಾ ।",
    "ಲಂಕೇಶ್ವರ ಭಯೇ ಸಬ ಜಗ ಜಾನಾ ॥",
    "ಯುಗ ಸಹಸ್ರ ಯೋಜನ ಪರ ಭಾನೂ ।",
    "ಲೀಲ್ಯೋ ತಾಹಿ ಮಧುರ ಫಲ ಜಾನೂ ॥",
    "ಪ್ರಭು ಮುದ್ರಿಕಾ ಮೇಲಿ ಮುಖ ಮಾಹೀ ।",
    "ಜಲಧಿ ಲಾಂಘಿ ಗಯೇ ಅಚರಜ ನಾಹೀ ॥",
    "ದುರ್ಗಮ ಕಾಜ ಜಗತ ಕೇ ಜೇತೇ ।",
    "ಸುಗಮ ಅನುಗ್ರಹ ತುಮ್ಹರೇ ತೇತೇ ॥",
    "ರಾಮ ದುಆರೇ ತುಮ ರಖವಾರೇ ।",
    "ಹೋತ ನ ಆಜ್ಞಾ ಬಿನು ಪೈಸಾರೇ ॥",
    "ಸಬ ಸುಖ ಲಹೈ ತುಮ್ಹಾರೀ ಶರಣಾ ।",
    "ತುಮ ರಕ್ಷಕ ಕಾಹೂ ಕೋ ಡರ ನಾ ॥",
    "ಆಪನ ತೇಜ ಸಮ್ಹಾರೋ ಆಪೈ ।",
    "ತೀನೋಂ ಲೋಕ ಹಾಂಕ ತೇ ಕಾಂಪೈ ॥",
    "ಭೂತ ಪಿಶಾಚ ನಿಕಟ ನಹಿ ಆವೈ ।",
    "ಮಹವೀರ ಜಬ ನಾಮ ಸುನಾವೈ ॥",
    "ನಾಸೈ ರೋಗ ಹರೈ ಸಬ ಪೀರಾ ।",
    "ಜಪತ ನಿರಂತರ ಹನುಮತ ವೀರಾ ॥",
    "ಸಂಕಟ ಸೇ ಹನುಮಾನ ಛುಡಾವೈ ।",
    "ಮನ ಕ್ರಮ ವಚನ ಧ್ಯಾನ ಜೋ ಲಾವೈ ॥",
    "ಸಬ ಪರ ರಾಮ ತಪಸ್ವೀ ರಾಜಾ ।",
    "ತಿನಕೇ ಕಾಜ ಸಕಲ ತುಮ ಸಾಜಾ ॥",
    "ಔರ ಮನೋರಥ ಜೋ ಕೋಯಿ ಲಾವೈ ।",
    "ತಾಸು ಅಮಿತ ಜೀವನ ಫಲ ಪಾವೈ ॥",
    "ಚಾರೋ ಯುಗ ಪ್ರತಾಪ ತುಮ್ಹಾರಾ ।",
    "ಹೈ ಪ್ರಸಿದ್ಧ ಜಗತ ಉಜಿಯಾರಾ ॥",
    "ಸಾಧು ಸಂತ ಕೇ ತುಮ ರಖವಾರೇ ।",
    "ಅಸುರ ನಿಕಂದನ ರಾಮ ದುಲಾರೇ ॥",
    "ಅಷ್ಠಸಿದ್ಧಿ ನವ ನಿಧಿ ಕೇ ದಾತಾ ।",
    "ಅಸ ವರ ದೀನ್ಹ ಜಾನಕೀ ಮಾತಾ ॥",
    "ರಾಮ ರಸಾಯನ ತುಮ್ಹಾರೇ ಪಾಸಾ ।",
    "ಸದಾ ರಹೋ ರಘುಪತಿ ಕೇ ದಾಸಾ ॥",
    "ತುಮ್ಹರೇ ಭಜನ ರಾಮಕೋ ಪಾವೈ ।",
    "ಜನ್ಮ ಜನ್ಮ ಕೇ ದುಖ ಬಿಸರಾವೈ ॥",
    "ಅಂತ ಕಾಲ ರಘುಪತಿ ಪುರಜಾಯೀ ।",
    "ಜಹಾಂ ಜನ್ಮ ಹರಿಭಕ್ತ ಕಹಾಯೀ ॥",
    "ಔರ ದೇವತಾ ಚಿತ್ತ ನ ಧರಯೀ ।",
    "ಹನುಮತ ಸೇಯಿ ಸರ್ವ ಸುಖ ಕರಯೀ ॥",
    "ಸಂಕಟ ಕ(ಹ)ಟೈ ಮಿಟೈ ಸಬ ಪೀರಾ ।",
    "ಜೋ ಸುಮಿರೈ ಹನುಮತ ಬಲ ವೀರಾ ॥",
    "ಜೈ ಜೈ ಜೈ ಹನುಮಾನ ಗೋಸಾಯೀ ।",
    "ಕೃಪಾ ಕರಹು ಗುರುದೇವ ಕೀ ನಾಯೀ ॥",
    "ಯಹ ಶತ ವಾರ ಪಾಠ ಕರ ಕೋಯೀ ।",
    "ಛೂಟಹಿ ಬಂದಿ ಮಹಾ ಸುಖ ಹೋಯೀ ॥",
    "ಜೋ ಯಹ ಪಡೈ ಹನುಮಾನ ಚಾಲೀಸಾ ।",
    "ಹೋಯ ಸಿದ್ಧಿ ಸಾಖೀ ಗೌರೀಶಾ ॥",
    "ತುಲಸೀದಾಸ ಸದಾ ಹರಿ ಚೇರಾ ।",
    "ಕೀಜೈ ನಾಥ ಹೃದಯ ಮಹ ಡೇರಾ ॥",

  ];


  final List<String> _kannadaAdityaMantraVerses = [
  "ನಮಸ್ಸವಿತ್ರೇ ಜಗದೇಕ ಚಕ್ಷುಸೇ",
  "ಜಗತ್ಪ್ರಸೂತಿ ಸ್ಥಿತಿ ನಾಶಹೇತವೇ",
  "ತ್ರಯೀಮಯಾಯ ತ್ರಿಗುಣಾತ್ಮ ಧಾರಿಣೇ",
  "ವಿರಿಂಚಿ ನಾರಾಯಣ ಶಂಕರಾತ್ಮನೇ",

  "ತತೋ ಯುದ್ಧ ಪರಿಶ್ರಾಂತಂ",
  "ಸಮರೇ ಚಿಂತಯಾಸ್ಥಿತಮ್",
  "ರಾವಣಂ ಚಾಗ್ರತೋ ದೃಷ್ಟ್ವಾ",
  "ಯುದ್ಧಾಯ ಸಮುಪಸ್ಥಿತಮ್ ",

  "ದೈವತೈಶ್ಚ ಸಮಾಗಮ್ಯ",
  "ದ್ರಷ್ಟುಮಭ್ಯಾಗತೋ ರಣಮ್",
  "ಉಪಾಗಮ್ಯಾಬ್ರವೀದ್ರಾಮಂ",
  "ಅಗಸ್ತ್ಯೋ ಭಗವಾನ್ ಋಷಿಃ ",

  "ರಾಮ ರಾಮ ಮಹಾಬಾಹೋ",
  "ಶೃಣು ಗುಹ್ಯಂ ಸನಾತನಮ್",
  "ಯೇನ ಸರ್ವಾನರೀನ್ ವತ್ಸ",
  "ಸಮರೇ ವಿಜಯಿಷ್ಯಸಿ ",

  "ಆದಿತ್ಯಹೃದಯಂ ಪುಣ್ಯಂ",
  "ಸರ್ವಶತ್ರು ವಿನಾಶನಮ್",
  "ಜಯಾವಹಂ ಜಪೇನ್ನಿತ್ಯಂ",
  "ಅಕ್ಷಯ್ಯಂ ಪರಮಂ ಶಿವಮ್ ",

  "ಸರ್ವಮಂಗಳ ಮಾಂಗಳ್ಯಂ",
  "ಸರ್ವಪಾಪ ಪ್ರಣಾಶನಮ್",
  "ಚಿಂತಾಶೋಕ ಪ್ರಶಮನಂ",
  "ಆಯುರ್ವರ್ಧನಮುತ್ತಮಮ್ ",

  "ರಶ್ಮಿಮಂತಂ ಸಮುದ್ಯಂತಂ",
  "ದೇವಾಸುರ ನಮಸ್ಕೃತಮ್",
  "ಪೂಜಯಸ್ವ ವಿವಸ್ವಂತಂ",
  "ಭಾಸ್ಕರಂ ಭುವನೇಶ್ವರಮ್ ",

  "ಸರ್ವದೇವಾತ್ಮಕೋ ಹ್ಯೇಷ",
  "ತೇಜಸ್ವೀ ರಶ್ಮಿಭಾವನಃ",
  "ಏಷ ದೇವಾಸುರ ಗಣಾನ್",
  "ಲೋಕಾನ್ ಪಾತಿ ಗಭಸ್ತಿಭಿಃ ",

  "ಏಷ ಬ್ರಹ್ಮಾ ಚ ವಿಷ್ಣುಶ್ಚ",

  "ಮಹೇಂದ್ರೋ ಧನದಃ ಕಾಲೋ",
  "ಯಮಃ ಸೋಮೋ ಹ್ಯಪಾಂ ಪತಿಃ ",

  "ಪಿತರೋ ವಸವಃ ಸಾಧ್ಯಾಃ",
  "ಅಶ್ವಿನೌ ಮರುತೋ ಮನುಃ",
  "ವಾಯುರ್ವಹ್ನಿಃ ಪ್ರಜಾಪ್ರಾಣಃ",
  "ಋತುಕರ್ತಾ ಪ್ರಭಾಕರಃ ",

  "ಆದಿತ್ಯಃ ಸವಿತಾ ಸೂರ್ಯಃ",
  "ಖಗಃ ಪೂಷಾ ಗಭಸ್ತಿಮಾನ್",
  "ಸುವರ್ಣಸದೃಶೋ ಭಾನುಃ",
  "ಹಿರಣ್ಯರೇತಾ ದಿವಾಕರಃ ",

  "ಹರಿದಶ್ವಃ ಸಹಸ್ರಾರ್ಚಿಃ",
  "ಸಪ್ತಸಪ್ತಿರ್ಮರೀಚಿಮಾನ್",
  "ತಿಮಿರೋನ್ಮಥನಃ ಶಂಭುಃ",
  "ತ್ವಷ್ಟಾ ಮಾರ್ತಾಂಡಕೋಽಂಶುಮಾನ್ ",

  "ಹಿರಣ್ಯಗರ್ಭಃ ಶಿಶಿರಃ",
  "ತಪನೋ ಭಾಸ್ಕರೋ ರವಿಃ",
  "ಅಗ್ನಿಗರ್ಭೋಽದಿತೇಃ ಪುತ್ರಃ",
  "ಶಂಖಃ ಶಿಶಿರನಾಶನಃ ",

  "ವ್ಯೋಮನಾಥಸ್ತಮೋಭೇದೀ",
  "ಋಗ್ಯಜುಃಸಾಮ ಪಾರಗಃ",
  "ಘನಾವೃಷ್ಟಿರಪಾಂ ಮಿತ್ರಃ",
  "ವಿಂಧ್ಯವೀಥೀ ಪ್ಲವಂಗಮಃ ",

  "ಆತಪೀ ಮಂಡಲೀ ಮೃತ್ಯುಃ",
  "ಪಿಂಗಳಃ ಸರ್ವತಾಪನಃ",
  "ಕವಿರ್ವಿಶ್ವೋ ಮಹಾತೇಜಾಃ",
  "ರಕ್ತಃ ಸರ್ವಭವೋದ್ಭವಃ ",

  "ನಕ್ಷತ್ರ ಗ್ರಹ ತಾರಾಣಾಂ",
  "ಅಧಿಪೋ ವಿಶ್ವಭಾವನಃ",
  "ತೇಜಸಾಮಪಿ ತೇಜಸ್ವೀ",
  "ದ್ವಾದಶಾತ್ಮನ್ನಮೋಽಸ್ತು ತೇ ",

  "ನಮಃ ಪೂರ್ವಾಯ ಗಿರಯೇ",
  "ಪಶ್ಚಿಮಾಯಾದ್ರಯೇ ನಮಃ",
  "ಜ್ಯೋತಿರ್ಗಣಾನಾಂ ಪತಯೇ",
  "ದಿನಾಧಿಪತಯೇ ನಮಃ ",

  "ಜಯಾಯ ಜಯಭದ್ರಾಯ",
  "ಹರ್ಯಶ್ವಾಯ ನಮೋ ನಮಃ",
  "ನಮೋ ನಮಃ ಸಹಸ್ರಾಂಶೋ",
  "ಆದಿತ್ಯಾಯ ನಮೋ ನಮಃ ",

  "ನಮ ಉಗ್ರಾಯ ವೀರಾಯ",
  "ಸಾರಂಗಾಯ ನಮೋ ನಮಃ",
  "ನಮಃ ಪದ್ಮಪ್ರಬೋಧಾಯ",
  "ಮಾರ್ಥಾಂಡಾಯ ನಮೋ ನಮಃ ",

  "ಬ್ರಹ್ಮೇಶಾನಾಚ್ಯುತೇಶಾಯ",
  "ಸೂರ್ಯಾಯಾದಿತ್ಯ ವರ್ಚಸೇ",
  "ಭಾಸ್ವತೇ ಸರ್ವಭಕ್ಷಾಯ",
  "ರೌದ್ರಾಯ ವಪುಷೇ ನಮಃ ",

  "ತಮೋಘ್ನಾಯ ಹಿಮಘ್ನಾಯ",
  "ಶತ್ರುಘ್ನಾಯಾ ಮಿತಾತ್ಮನೇ",
  "ಕೃತಘ್ನಘ್ನಾಯ ದೇವಾಯ",
  "ಜ್ಯೋತಿಷಾಂ ಪತಯೇ ನಮಃ ",

  "ತಪ್ತ ಚಾಮೀಕರಾಭಾಯ",
  "ವಹ್ನಯೇ ವಿಶ್ವಕರ್ಮಣೇ",
  "ನಮಸ್ತಮೋಽಭಿ ನಿಘ್ನಾಯ",
  "ರವಯೇ ಲೋಕಸಾಕ್ಷಿಣೇ",

  "ನಾಶಯತ್ಯೇಷ ವೈ ಭೂತಂ",
  "ತದೇವ ಸೃಜತಿ ಪ್ರಭುಃ",
  "ಪಾಯತ್ಯೇಷ ತಪತ್ಯೇಷ",
  "ವರ್ಷತ್ಯೇಷ ಗಭಸ್ತಿಭಿಃ ",

  "ಏಷ ಸುಪ್ತೇಷು ಜಾಗರ್ತಿ",
  "ಭೂತೇಷು ಪರಿನಿಷ್ಠಿತಃ",
  "ಏಷ ಏವಾಗ್ನಿಹೋತ್ರಂ ಚ",
  "ಫಲಂ ಚೈವಾಗ್ನಿಹೋತ್ರಿಣಾಮ್ ",

  "ವೇದಾಶ್ಚ ಕ್ರತವಶ್ಚೈವ",
  "ಕ್ರತೂನಾಂ ಫಲಮೇವ ಚ",
  "ಯಾನಿ ಕೃತ್ಯಾನಿ ಲೋಕೇಷು",
  "ಸರ್ವ ಏಷ ರವಿಃ ಪ್ರಭುಃ ",

  "ಏನ ಮಾಪತ್ಸು ಕೃಚ್ಛ್ರೇಷು",
  "ಕಾಂತಾರೇಷು ಭಯೇಷು ಚ",
  "ಕೀರ್ತಯನ್ ಪುರುಷಃ ಕಶ್ಚಿನ್",
  "ನಾವಶೀದತಿ ರಾಘವ ",

  "ಪೂಜಯಸ್ವೈನ ಮೇಕಾಗ್ರಃ",
  "ದೇವದೇವಂ ಜಗತ್ಪತಿಂ",
  "ಏತತ್ ತ್ರಿಗುಣಿತಂ ಜಪ್ತ್ವಾ",
  "ಯುದ್ಧೇಷು ವಿಜಯಿಷ್ಯಸಿ ",

  "ಅಸ್ಮಿನ್ ಕ್ಷಣೇ ಮಹಾಬಾಹೋ",
  "ರಾವಣಂ ತ್ವಂ ವಧಿಷ್ಯಸಿ",
  "ಏವಮುಕ್ತ್ವಾ ತದಾಗಸ್ತ್ಯೋ",
  "ಜಗಾಮ ಚ ಯಥಾಗತಮ್",

  "ಏತಚ್ಛ್ರುತ್ವಾ ಮಹಾತೇಜಾಃ",
  "ನಷ್ಟಶೋಕೋಽಭವತ್ತದಾ",
  "ಧಾರಯಾಮಾಸ ಸುಪ್ರೀತಃ",
  "ರಾಘವಃ ಪ್ರಯತಾತ್ಮವಾನ್ ",

  "ಆದಿತ್ಯಂ ಪ್ರೇಕ್ಷ್ಯ ಜಪ್ತ್ವಾ ತು",
  "ಪರಂ ಹರ್ಷಮವಾಪ್ತವಾನ್",
  "ತ್ರಿರಾಚಮ್ಯ ಶುಚಿರ್ಭೂತ್ವಾ",
  "ಧನುರಾದಾಯ ವೀರ್ಯವಾನ್",

  "ರಾವಣಂ ಪ್ರೇಕ್ಷ್ಯ ಹೃಷ್ಟಾತ್ಮಾ",
  "ಯುದ್ಧಾಯ ಸಮುಪಾಗಮತ್",
  "ಸರ್ವಯತ್ನೇನ ಮಹತಾ",
  "ವಧೇ ತಸ್ಯ ಧೃತೋಽಭವತ್ ",

  "ಅಧ ರವಿರವದನ್ನಿರೀಕ್ಷ್ಯ ರಾಮಂ",
  "ಮುದಿತಮನಾಃ ಪರಮಂ ಪ್ರಹೃಷ್ಯಮಾಣಃ",
  "ನಿಶಿಚರಪತಿ ಸಂಕ್ಷಯಂ ವಿದಿತ್ವಾ",
  "ಸುರಗಣ ಮಧ್ಯಗತೋ ವಚಸ್ತ್ವರೇತಿ ",

  "ಇತ್ಯಾರ್ಷೇ ಶ್ರೀಮದ್ರಾಮಾಯಣೇ ವಾಲ್ಮಿಕೀಯೇ",
  "ಆದಿಕಾವ್ಯೇ ಯುದ್ಧಕಾಂಡೇ ಪಂಚಾಧಿಕ ಶತತಮಃ ಸರ್ಗಃ ॥"
  ];


  @override
  void initState() {
    super.initState();

    // Initialize mantra display based on widget.mantra
    showHanumanChalisa = widget.mantra == 'Hanuman Chalisa';
    showAdityaMantra = widget.mantra == 'Aditya Hrudayam';
    // No mantra display or audio for 'None'

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

    _inhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _exhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _chalisaPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _adityaMantraPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _preloadAudio();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalDuration.toInt()),
    );

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

    // Start mantra audio only if a mantra is selected
    if (showHanumanChalisa) {
      _chalisaPlayer.resume();
    } else if (showAdityaMantra) {
      _adityaMantraPlayer.resume();
    }
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

    if (newActiveSide != _activeSide) {
      setState(() {
        _activeSide = newActiveSide;
      });
    }

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
      _resetSideReadStatus();

      if (showHanumanChalisa || showAdityaMantra) {
        setState(() {
          List<String> currentVerses = _getCurrentVerses();
          _currentVerseIndex = (_currentVerseIndex + 4) % currentVerses.length;
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
      switch (_selectedLanguage) {
        case "English":
          return _englishAdityaMantraVerses;
        case "Kannada":
          return _kannadaAdityaMantraVerses;
        default:
          return _adityaMantraVerses;
      }
    } else if (showHanumanChalisa) {
      switch (_selectedLanguage) {
        case "English":
          return _englishHanumanChalisaVerses;
        case "Kannada":
          return _kannadaHanumanChalisaVerses;
        default:
          return _hanumanChalisaVerses;
      }
    }
    return []; // Return empty list for No Mantra
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
      _chalisaPlayer.stop(),
      _adityaMantraPlayer.stop(),
    ]);
  }

  Future<void> toggleAudio() async {
    final newVolume = isAudioPlaying ? 0.0 : 1.0;
    await Future.wait([
      _inhalePlayer.setVolume(newVolume),
      _exhalePlayer.setVolume(newVolume),
      _chalisaPlayer.setVolume(newVolume),
      _adityaMantraPlayer.setVolume(newVolume),
    ]);
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
    // Ensure mantra audio is controlled based on selection
    if (isAudioPlaying) {
      if (showHanumanChalisa) {
        await _chalisaPlayer.resume();
      } else if (showAdityaMantra) {
        await _adityaMantraPlayer.resume();
      }
    } else {
      await _chalisaPlayer.stop();
      await _adityaMantraPlayer.stop();
    }
  }

  void _setLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
      _currentVerseIndex = 0;
      _resetSideReadStatus();
    });
  }

  void markSideAsRead(String side) {
    if ((showHanumanChalisa || showAdityaMantra) && side == _activeSide &&
        !_sideRead[side]!) {
      setState(() {
        _sideRead[side] = true;
      });
    }
  }

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
    return index % currentVerses.length;
  }

  Offset _calculateCirclePosition(double t, double size) {
    if (t < _f1) {
      double fraction = t / _f1;
      double x = fraction * size;
      double y = 0;
      return Offset(x, y);
    } else if (t < _f2) {
      double fraction = (t - _f1) / (_f2 - _f1);
      double x = size;
      double y = fraction * size;
      return Offset(x, y);
    } else if (t < _f3) {
      double fraction = (t - _f2) / (_f3 - _f2);
      double x = size * (1 - fraction);
      double y = size;
      return Offset(x, y);
    } else {
      double fraction = (t - _f3) / (1 - _f3);
      double x = 0;
      double y = size * (1 - fraction);
      return Offset(x, y);
    }
  }

  Widget _buildVerseWidget(String side, bool isActive) {
    if (!showHanumanChalisa && !showAdityaMantra) {
      return SizedBox.shrink(); // Return empty widget if no mantra is selected
    }

    int verseIndex = _getVerseIndexForSide(side);
    List<String> currentVerses = _getCurrentVerses();

    if (verseIndex >= currentVerses.length) {
      verseIndex = currentVerses.length - 1;
    }

    String verse = currentVerses.isNotEmpty ? currentVerses[verseIndex] : "";
    bool isRead = _sideRead[side]!;

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
          if (showHanumanChalisa || showAdityaMantra) ...[
            Positioned(
              top: 0,
              left: textPadding + 20,
              right: textPadding + 20,
              child: _buildVerseWidget("top", _activeSide == "top"),
            ),
            Positioned(
              right: 0,
              top: textPadding + 20,
              bottom: textPadding + 20,
              width: textPadding * 2,
              child: _buildVerseWidget("right", _activeSide == "right"),
            ),
            Positioned(
              bottom: 0,
              left: textPadding + 20,
              right: textPadding + 20,
              child: _buildVerseWidget("bottom", _activeSide == "bottom"),
            ),
            Positioned(
              left: 0,
              top: textPadding + 20,
              bottom: textPadding + 20,
              width: textPadding * 2,
              child: _buildVerseWidget("left", _activeSide == "left"),
            ),
          ],
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              Offset circleCenter = _calculateCirclePosition(
                  _controller.value, boxSize);

              Color ballColor;
              Color glowColor;

              if (_currentPhase == "Inhale") {
                ballColor = Color(0xFF1E88E5);
                glowColor = Color(0xFF1E88E5).withOpacity(0.5);
              } else if (_currentPhase == "Exhale") {
                ballColor = Color(0xFFE57373);
                glowColor = Color(0xFFE57373).withOpacity(0.5);
              } else {
                ballColor = Color(0xFFFFB74D);
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

  Widget _buildBreathingPhaseText() {
    Color textColor;

    switch (_currentPhase) {
      case "Inhale":
        textColor = Color(0xFF1E88E5);
        break;
      case "Exhale":
        textColor = Color(0xFFE57373);
        break;
      case "Hold":
        textColor = Color(0xFFFFB74D);
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
            "Round ${_currentRound < widget.rounds ? _currentRound + 1 : widget.rounds} of ${widget.rounds}",
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

  Widget _buildVersesProgressIndicator() {
    bool showIndicator = showHanumanChalisa || showAdityaMantra;
    IconData indicatorIcon = showAdityaMantra ? Icons.wb_sunny : Icons.auto_stories;
    Color indicatorColor = showAdityaMantra ? Color(0xFFFF5722) : Color(0xFFFF9800);
    List<String> currentVerses = showAdityaMantra ? _adityaMantraVerses : _hanumanChalisaVerses;
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
              "$textType ${_currentVerseIndex + 1}-${min(_currentVerseIndex + 4, currentVerses.length)} of ${currentVerses.length}",
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
    _chalisaPlayer.dispose();
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
                    _buildBreathingPhaseText(),
                    SizedBox(height: 30),
                    _buildBoxAnimation(),
                    SizedBox(height: 25),
                    _buildVersesProgressIndicator(),
                    SizedBox(height: 16),
                    _buildRoundsIndicator(),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButtons(),
                        SizedBox(width: 16),
                      ],
                    ),
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

class AnimatedBackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  AnimatedBackgroundPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value;

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
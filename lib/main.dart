import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

void main() => runApp(const QuranNoorApp());

class QuranNoorApp extends StatelessWidget {
  const QuranNoorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ٱلۡقُرۡآنُ ٱلۡكَرِيمُ',
      theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: Colors.black),
      home: const QuranNoorHome(),
    );
  }
}

class QuranNoorHome extends StatelessWidget {
  const QuranNoorHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ٱلۡقُرۡآنُ ٱلۡكَرِيمُ - مصحف المدينة", style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212)
      ),
      body: ListView.builder(
        itemCount: 114,
        itemBuilder: (context, i) {
          int num = i + 1;
          return Card(
            color: const Color(0xFF121212),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.amber.shade900, child: Text("$num", style: const TextStyle(color: Colors.white))),
              title: Text(quran.getSurahNameArabic(num), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF5E6C8))),
              subtitle: Text("${quran.getVerseCount(num)} آية"),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 18),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahNoorPage(surahNumber: num))),
            ),
          );
        },
      ),
    );
  }
}

class SurahNoorPage extends StatefulWidget {
  final int surahNumber;
  const SurahNoorPage({super.key, required this.surahNumber});
  @override
  State<SurahNoorPage> createState() => _SurahNoorPageState();
}

class _SurahNoorPageState extends State<SurahNoorPage> {
  final player = AudioPlayer();
  bool isPlaying = false;
  String selectedReciter = "عبد الباسط";
  final Map<String, String> reciters = {
    "عبد الباسط": "Abdul_Basit_Murattal_192kbps",
    "المنشاوي": "Minshawy_Murattal_128kbps",
    "ياسر الدوسري": "Yasser_Ad-Dosari_128kbps",
  };

  Future<void> playSurah() async {
    if (isPlaying) { await player.pause(); setState(() => isPlaying = false); return; }
    int count = quran.getVerseCount(widget.surahNumber);
    String code = reciters[selectedReciter]!;
    List<AudioSource> sources = [];
    for (int i = 1; i <= count; i++) {
      String sId = widget.surahNumber.toString().padLeft(3, '0');
      String vId = i.toString().padLeft(3, '0');
      sources.add(AudioSource.uri(Uri.parse("https://everyayah.com/data/$code/$sId$vId.mp3")));
    }
    await player.setAudioSource(ConcatenatingAudioSource(children: sources));
    await player.play();
    setState(() => isPlaying = true);
  }

  @override
  void dispose() { player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    int count = quran.getVerseCount(widget.surahNumber);

    // هنا نسوي النص كله وره بعض مثل المصحف
    List<TextSpan> spans = [];
    for (int i = 0; i < count; i++) {
      spans.add(TextSpan(
        text: "${quran.getVerse(widget.surahNumber, i + 1)} ",
        style: const TextStyle(fontSize: 26, height: 2.2, color: Color(0xFFF5E6C8)),
      ));
      spans.add(TextSpan(
        text: "﴿${i + 1}﴾ ",
        style: const TextStyle(fontSize: 24, height: 2.2, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(quran.getSurahNameArabic(widget.surahNumber)),
        backgroundColor: const Color(0xFF121212),
        actions: [
          DropdownButton<String>(
            value: selectedReciter,
            dropdownColor: const Color(0xFF121212),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.amber, fontSize: 12),
            items: reciters.keys.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) async { if (v!= null) { await player.stop(); setState(() { selectedReciter = v; isPlaying = false; }); } },
          )
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF121212),
          child: Row(children: [
            IconButton(icon: Icon(isPlaying? Icons.pause_circle_filled : Icons.play_circle_filled, size: 45, color: Colors.amber), onPressed: playSurah),
            const SizedBox(width: 8),
            const Text("اضغط للاستماع", style: TextStyle(color: Colors.white70)),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                if (widget.surahNumber!= 1 && widget.surahNumber!= 9)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  ),
                // هذا هو المهم - الآيات وره بعض
                RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(children: spans),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                  child: const Column(children: [
                    Text("الفاتحة الى المرحوم ناصر عزيز", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 12),
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.9, color: Color(0xFFF5E6C8))),
                  ]),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
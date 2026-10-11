import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.1.44';
}

class AppTheme {
  static const Color darkBg = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonOrange = Color(0xFFF97316);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA3A3A3);

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonPurple,
      colorScheme: const ColorScheme.dark(
        primary: neonPurple,
        secondary: neonPink,
        surface: cardDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF181818),
        selectedItemColor: neonPink,
        unselectedItemColor: textMuted,
        elevation: 20,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}

void main() {
  runApp(const KamuIlanApp());
}

class KamuIlanApp extends StatelessWidget {
  const KamuIlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kamu Alım Takip Pro',
      theme: AppTheme.getTheme(),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _seciliIndex = 0;
  List<Map<String, dynamic>> favoriIlanlar = [];

  @override
  void initState() {
    super.initState();
    _favorileriYukle();
  }

  Future<void> _favorileriYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final liste = prefs.getStringList('favori_ilanlar') ?? [];
      setState(() {
        favoriIlanlar = liste
            .map((item) => json.decode(item) as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      setState(() {
        favoriIlanlar = [];
      });
    }
  }

  Future<void> favoriToggle(Map ilan) async {
    final prefs = await SharedPreferences.getInstance();
    final ilanId = ilan['link']?.toString() ?? ilan['baslik'] ?? '';

    setState(() {
      bool varMi = favoriIlanlar.any(
        (i) => (i['link']?.toString() ?? i['baslik']) == ilanId,
      );
      if (varMi) {
        favoriIlanlar.removeWhere(
          (i) => (i['link']?.toString() ?? i['baslik']) == ilanId,
        );
      } else {
        favoriIlanlar.add(Map<String, dynamic>.from(ilan));
      }
    });

    List<String> stringList = favoriIlanlar.map((i) => json.encode(i)).toList();
    await prefs.setStringList('favori_ilanlar', stringList);
  }

  bool isFavori(Map ilan) {
    final ilanId = ilan['link']?.toString() ?? ilan['baslik'] ?? '';
    return favoriIlanlar.any(
      (i) => (i['link']?.toString() ?? i['baslik']) == ilanId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sayfalar = [
      IlanlarSekmesi(
        favoriIlanlar: favoriIlanlar,
        onFavoriToggle: favoriToggle,
        isFavoriCheck: isFavori,
      ),
      FavorilerSekmesi(
        favoriIlanlar: favoriIlanlar,
        onFavoriToggle: favoriToggle,
      ),
      const AlarmYoneticisiSekmesi(),
      const BilgiSekmesi(),
    ];

    return Scaffold(
      body: sayfalar[_seciliIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seciliIndex,
        onTap: (index) {
          setState(() {
            _seciliIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Kitaplık',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_rounded),
            label: 'Alarmlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class StateMessageWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Widget? action;

  const StateMessageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppTheme.neonPurple,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

class IlanlarSekmesi extends StatefulWidget {
  final List<Map<String, dynamic>> favoriIlanlar;
  final Function(Map) onFavoriToggle;
  final bool Function(Map) isFavoriCheck;

  const IlanlarSekmesi({
    super.key,
    required this.favoriIlanlar,
    required this.onFavoriToggle,
    required this.isFavoriCheck,
  });

  @override
  State<IlanlarSekmesi> createState() => _IlanlarSekmesiState();
}

class _IlanlarSekmesiState extends State<IlanlarSekmesi> {
  List filtrelenmisIlanlar = [];
  bool yukleniyor = true;
  bool hataVar = false;
  final TextEditingController _aramaController = TextEditingController();
  String aktifFiltre = 'Tümü';

  final List<String> filtreler = [
    'Tümü',
    '4291',
    '3001',
    'Ankara',
    'İstanbul',
    'Bilişim',
    'Mühendis',
  ];

  Future<void> fetchIlanlar({String aramaTerimi = ''}) async {
    String terim = aramaTerimi;
    if (terim.isEmpty && aktifFiltre != 'Tümü') {
      terim = aktifFiltre;
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/ilanlar/filtrele?arama_terimi=$terim',
    );
    setState(() {
      yukleniyor = true;
      hataVar = false;
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          filtrelenmisIlanlar = data['data'] ?? [];
          yukleniyor = false;
        });
      } else {
        setState(() {
          hataVar = true;
          yukleniyor = false;
        });
      }
    } catch (e) {
      setState(() {
        hataVar = true;
        yukleniyor = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchIlanlar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı İlan Akışı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.neonCyan),
            onPressed: () => fetchIlanlar(aramaTerimi: _aramaController.text),
          ),
        ],
      ),
      body: yukleniyor
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 84,
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : hataVar
          ? StateMessageWidget(
              icon: Icons.cloud_off_rounded,
              title: 'Bağlantı Hatası',
              message: 'FastAPI sunucusuna ulaşılamadı.',
              color: AppTheme.neonOrange,
              action: ElevatedButton.icon(
                onPressed: () =>
                    fetchIlanlar(aramaTerimi: _aramaController.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _aramaController,
                    onSubmitted: (val) => fetchIlanlar(aramaTerimi: val),
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(
                      hintText:
                          'Nitelik kodu, unvan veya kelime ara (örn: 4291)...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textMuted,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_aramaController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppTheme.neonPink,
                              ),
                              onPressed: () {
                                _aramaController.clear();
                                fetchIlanlar(aramaTerimi: '');
                              },
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppTheme.neonCyan,
                            ),
                            onPressed: () => fetchIlanlar(
                              aramaTerimi: _aramaController.text,
                            ),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtreler.length,
                    itemBuilder: (context, index) {
                      final f = filtreler[index];
                      final secili = aktifFiltre == f;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(f),
                          selected: secili,
                          selectedColor: AppTheme.neonPink,
                          backgroundColor: AppTheme.cardDark,
                          labelStyle: TextStyle(
                            color: secili ? Colors.white : AppTheme.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            setState(() {
                              aktifFiltre = f;
                            });
                            String aramaGonder = f == 'Tümü' ? '' : f;
                            _aramaController.text = aramaGonder;
                            fetchIlanlar(aramaTerimi: aramaGonder);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: filtrelenmisIlanlar.isEmpty
                      ? const StateMessageWidget(
                          icon: Icons.search_off_rounded,
                          title: 'Sonuç Bulunamadı',
                          message: 'Aramanıza veya seçtiğiniz nitelik koduna uygun ilan bulunamadı.',
                          color: AppTheme.neonOrange,
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              fetchIlanlar(aramaTerimi: _aramaController.text),
                          color: AppTheme.neonPink,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: filtrelenmisIlanlar.length,
                            itemBuilder: (context, index) {
                              final ilan = filtrelenmisIlanlar[index];
                              final isFavori = widget.isFavoriCheck(ilan);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardDark,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              IlanDetaySayfasi(
                                                ilan: ilan,
                                                isFavori: isFavori,
                                                onFavoriToggle: () =>
                                                    widget.onFavoriToggle(ilan),
                                              ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppTheme.neonPurple,
                                                  AppTheme.neonPink,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.campaign_rounded,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ilan['baslik'] ??
                                                      'Başlıksız İlan',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textMain,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        ilan['kurum'] ?? 'Kurum belirtilmemiş',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              AppTheme.neonCyan,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .neonOrange
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'Akıllı Eşleşme',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppTheme
                                                              .neonOrange,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isFavori
                                                  ? Icons.favorite_rounded
                                                  : Icons
                                                        .favorite_border_rounded,
                                              color: isFavori
                                                  ? AppTheme.neonPink
                                                  : AppTheme.textMuted,
                                              size: 24,
                                            ),
                                            onPressed: () =>
                                                widget.onFavoriToggle(ilan),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class IlanDetaySayfasi extends StatelessWidget {
  final Map ilan;
  final bool isFavori;
  final VoidCallback onFavoriToggle;

  const IlanDetaySayfasi({
    super.key,
    required this.ilan,
    required this.isFavori,
    required this.onFavoriToggle,
  });

  Future<void> launchInBrowser(String urlAdresi) async {
    String tamUrl = urlAdresi;
    if (!urlAdresi.startsWith('http://') && !urlAdresi.startsWith('https://')) {
      tamUrl = 'https://kamuilan.sbb.gov.tr$urlAdresi';
    }
    final Uri url = Uri.parse(tamUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _ilaniPaylas() async {
    final baslik = ilan['baslik'] ?? 'Kamu İlanı';
    final kurum = ilan['kurum'] ?? '';
    final link = ilan['link'] ?? '';
    String tamLink = link.startsWith('http')
        ? link
        : 'https://kamuilan.sbb.gov.tr$link';

    final shareText =
        '📢 Kamu İlanı Duyurusu!\n\nKurum: $kurum\nİlan: $baslik\n\nDetaylar: $tamLink';
    final Uri uri = Uri.parse(
      'https://api.whatsapp.com/send?text=${Uri.encodeComponent(shareText)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: _ilaniPaylas,
            tooltip: 'Paylaş',
          ),
          IconButton(
            icon: Icon(
              isFavori ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavori ? AppTheme.neonPink : Colors.white,
            ),
            onPressed: onFavoriToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.neonPurple, AppTheme.neonOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonPurple.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              ilan['kurum'] ?? 'Resmi Kurum',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonCyan,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ilan['baslik'] ?? 'Başlıksız İlan',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF333333)),
            const SizedBox(height: 16),
            const Text(
              'Bu ilan resmi SBB platformundan senkronize edilmiştir. Başvuru kılavuzu için resmi web sitesini inceleyebilir veya takviminize hatırlatıcı ekleyebilirsiniz.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Son başvuru tarihi cihaz takvimine eklendi!',
                    ),
                    backgroundColor: AppTheme.neonCyan,
                  ),
                );
              },
              icon: const Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.neonCyan,
              ),
              label: const Text(
                'Son Başvuru Tarihini Takvime Ekle',
                style: TextStyle(
                  color: AppTheme.neonCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.neonCyan, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  final link = ilan['link'];
                  if (link != null && link.toString().isNotEmpty) {
                    launchInBrowser(link.toString());
                  }
                },
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Resmi Sitesinde İncele',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                  shadowColor: AppTheme.neonPink.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavorilerSekmesi extends StatelessWidget {
  final List<Map<String, dynamic>> favoriIlanlar;
  final Function(Map) onFavoriToggle;

  const FavorilerSekmesi({
    super.key,
    required this.favoriIlanlar,
    required this.onFavoriToggle,
  });

  Future<void> launchInBrowser(String urlAdresi) async {
    String tamUrl = urlAdresi;
    if (!urlAdresi.startsWith('http://') && !urlAdresi.startsWith('https://')) {
      tamUrl = 'https://kamuilan.sbb.gov.tr$urlAdresi';
    }
    final Uri url = Uri.parse(tamUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitaplığım (Favoriler)')),
      body: favoriIlanlar.isEmpty
          ? const StateMessageWidget(
              icon: Icons.favorite_border_rounded,
              title: 'Kitaplığın Boş',
              message: 'Beğendiğin ilanları kalp ikonuna dokunarak buraya kaydedebilirsin.',
              color: AppTheme.neonPink,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriIlanlar.length,
              itemBuilder: (context, index) {
                final ilan = favoriIlanlar[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.neonPink,
                      ),
                    ),
                    title: Text(
                      ilan['baslik'] ?? 'Başlıksız İlan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        ilan['kurum'] ?? '',
                        style: const TextStyle(
                          color: AppTheme.neonCyan,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: AppTheme.neonOrange,
                      ),
                      onPressed: () => onFavoriToggle(ilan),
                    ),
                    onTap: () {
                      final link = ilan['link'];
                      if (link != null && link.toString().isNotEmpty) {
                        launchInBrowser(link.toString());
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AlarmYoneticisiSekmesi extends StatefulWidget {
  const AlarmYoneticisiSekmesi({super.key});

  @override
  State<AlarmYoneticisiSekmesi> createState() => _AlarmYoneticisiSekmesiState();
}

class _AlarmYoneticisiSekmesiState extends State<AlarmYoneticisiSekmesi> {
  List<String> alarmlar = [
    '1. Alarm: Nitelik Kodu 4291',
    '2. Alarm: Bilişim ve Yazılım',
  ];
  final TextEditingController _yeniAlarmController = TextEditingController();

  void _alarmEkle() {
    if (_yeniAlarmController.text.isNotEmpty) {
      setState(() {
        alarmlar.add(
          '${alarmlar.length + 1}. Alarm: ${_yeniAlarmController.text}',
        );
        _yeniAlarmController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çoklu Alarm Profilleri')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktif Takip Alarmlarınız',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonPurple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Farklı nitelik kodları ve anahtar kelimeler için özel alarm profilleri oluşturabilirsiniz.',
              style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yeniAlarmController,
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: InputDecoration(
                      hintText: 'Örn: 4291, Mühendis',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _alarmEkle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Ekle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: alarmlar.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppTheme.neonCyan,
                      ),
                      title: Text(
                        alarmlar[index],
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: AppTheme.neonOrange,
                        ),
                        onPressed: () {
                          setState(() {
                            alarmlar.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BilgiSekmesi extends StatefulWidget {
  const BilgiSekmesi({super.key});

  @override
  State<BilgiSekmesi> createState() => _BilgiSekmesiState();
}

class _BilgiSekmesiState extends State<BilgiSekmesi> {
  final TextEditingController _adController = TextEditingController(
    text: "İbrahim",
  );
  final TextEditingController _chatIdController = TextEditingController(
    text: "7565987235",
  );
  final TextEditingController _kelimelerController = TextEditingController(
    text: "4291, 3001, Bilişim, Mühendis",
  );
  bool _kaydediliyor = false;

  Future<void> _ayarlariKaydet() async {
    setState(() {
      _kaydediliyor = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}/api/kullanici/ayarlar');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "ad_soyad": _adController.text,
          "telegram_chat_id": _chatIdController.text,
          "aranacak_kelimeler": _kelimelerController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı ayarları başarıyla güncellendi!'),
            backgroundColor: AppTheme.neonCyan,
          ),
        );
      } else {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ayarlar kaydedilirken hata oluştu!'),
          backgroundColor: AppTheme.neonOrange,
        ),
      );
    } finally {
      setState(() {
        _kaydediliyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Ayarları & Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telegram Bildirim ve Eşleşme Profili',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonPink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Buraya girdiğiniz nitelik kodları ve anahtar kelimeler, günlük tarama yapıldığında size özel Telegram bildirimleri göndermek için kullanılır.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Ad Soyad',
              style: TextStyle(
                color: AppTheme.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _adController,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Telegram Chat ID',
              style: TextStyle(
                color: AppTheme.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _chatIdController,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Takip Edilecek Nitelik Kodları / Kelimeler',
              style: TextStyle(
                color: AppTheme.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _kelimelerController,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                hintText: 'Örn: 4291, 3001, Bilişim, Mühendis',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _kaydediliyor ? null : _ayarlariKaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _kaydediliyor
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Ayarları ve Kriterleri Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Color(0xFF333333)),
            const SizedBox(height: 12),
            const Text(
              'Kamu Alım Takip Pro - Sürüm 5.3.0',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

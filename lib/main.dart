import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translationAnimation; // Gerakan muncul dari lubang
  late Animation<double> _holeAnimation; // Mengatur lubang mengecil/menghilang
  late Animation<double> _rotationAnimation; // Rotasi logo

  @override
  void initState() {
    super.initState();

    // Animation controller untuk seluruh animasi
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Animasi translasi: Logo muncul dari lubang ke posisi tengah
    _translationAnimation = Tween<double>(begin: 30, end: -100).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    // Animasi lubang mengecil (menghilang)
    _holeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.3, 0.5, curve: Curves.easeInOut)),
    );

    // Animasi rotasi logo: Mulai setelah logo mencapai posisi tengah
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    // Mulai animasi saat halaman dimuat
    _controller.forward();

    // Navigasi ke halaman login setelah animasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Lubang (menghilang di tengah animasi)
                if (_holeAnimation.value > 0)
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 + 100,
                    child: CustomPaint(
                      painter: HolePainter(holeScale: _holeAnimation.value),
                      size: Size(200, 100),
                    ),
                  ),

                // Logo dan center image bergerak ke atas
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 +
                      _translationAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Logo (berputar setelah berada di tengah)
                      RotationTransition(
                        turns: _rotationAnimation,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 150,
                          height: 150,
                        ),
                      ),

                      // Center image (statis di tengah logo)
                      Image.asset(
                        'assets/images/center_image.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                ),

                // Teks "Powered By" dan logo perusahaan di bawah logo
                Positioned(
                  bottom: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Powered by',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      // Logo perusahaan
                      Image.asset(
                        'assets/images/company_logo.png', // Ganti dengan path gambar perusahaan Anda
                        width: 100,
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final double holeScale; // Skala lubang (mengecil hingga menghilang)

  HolePainter({required this.holeScale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Gradien bayangan dalam yang bergradasi (Shadow inside the hole)
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Colors.black.withOpacity(1), // Bayangan luar (lebih gelap)
          Colors.transparent, // Bagian tengah lubang transparan
        ],
        stops: [0.0, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: center,
          width: 150 * holeScale,  // Lebar lubang yang menyesuaikan dengan skala
          height: 75 * holeScale,  // Tinggi lubang yang menyesuaikan dengan skala
        ),
      )
      ..style = PaintingStyle.fill;

    // Warna lubang (di tengah)
    final holePaint = Paint()
      ..color = const Color.fromARGB(225, 255, 219, 87) // Warna lubang
      ..style = PaintingStyle.fill;

    // Gambar bayangan di dalam lubang (lebih besar dari lubang untuk menciptakan gradasi)
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 150 * holeScale,  // Ukuran bayangan mengikuti ukuran lubang
        height: 75 * holeScale,  // Ukuran bayangan mengikuti ukuran lubang
      ),
      shadowPaint, // Bayangan bergradasi di dalam
    );

    // Gambar lubang (warna lebih terang di tengah)
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 150 * holeScale, // Ukuran lubang
        height: 75 * holeScale, // Ukuran lubang
      ),
      holePaint, // Warna lubang
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _topWaveAnimation;
  late Animation<Offset> _bottomWaveAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Animasi top wave dari atas ke posisi awal
    _topWaveAnimation = Tween<Offset>(
      begin: Offset(0, -1), // Di luar layar (atas)
      end: Offset(0, 0),    // Posisi normal
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Animasi bottom wave dari bawah ke posisi awal
    _bottomWaveAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Di luar layar (bawah)
      end: Offset(0, 0),   // Posisi normal
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Animasi fade-in untuk konten login
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeIn), // Mulai setelah setengah animasi berjalan
    );

    // Jalankan animasi
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animasi Top Wave
            SlideTransition(
              position: _topWaveAnimation,
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/top_wave.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Animasi Fade-In untuk Form Login
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome to,",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      "SISKA!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB300), // Warna kuning
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sistem Inspeksi Keselamatan Kerja",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Email
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Password
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: const Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Sign In
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Tambahkan logika login di sini
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Animasi Bottom Wave
            SlideTransition(
              position: _bottomWaveAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bottom_wave.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
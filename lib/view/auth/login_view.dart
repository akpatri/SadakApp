import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/app_provider.dart';
import '../../view_model/login_view_model.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _phoneController =
      TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginVMProvider);
    final vm = ref.read(loginVMProvider.notifier);

    ref.listen<LoginState>(loginVMProvider, (previous, next) {

      // ✅ Open OTP sheet only once
      if (previous?.codeSent == false && next.codeSent) {
        _showOtpBottomSheet(context);
      }

      // ✅ Navigate to home
      if (previous?.loggedIn == false && next.loggedIn) {
        Navigator.pop(context); // close bottom sheet
        context.go('/home');
      }

      // ✅ Show error
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/logo.png",
              height: 300,
            ),

            const SizedBox(height: 40),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "+91 Phone number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => vm.sendOtp(
                          _phoneController.text.trim(),
                        ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _OtpBottomSheet(),
    );
  }
}

class _OtpBottomSheet extends ConsumerStatefulWidget {
  const _OtpBottomSheet();

  @override
  ConsumerState<_OtpBottomSheet> createState() =>
      _OtpBottomSheetState();
}

class _OtpBottomSheetState
    extends ConsumerState<_OtpBottomSheet> {

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _otp =>
      _controllers.map((e) => e.text).join();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginVMProvider);
    final vm = ref.read(loginVMProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Verify OTP",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                child: TextField(
                  controller: _controllers[index],
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => vm.verifyOtp(_otp),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Verify"),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

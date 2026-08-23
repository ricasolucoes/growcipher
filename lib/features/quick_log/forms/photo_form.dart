import 'package:flutter/material.dart';

/// Foto. Sem formulário enquanto a galeria privada não existir (fase futura
/// do roadmap): a ação aparece desabilitada no menu "O que aconteceu?" e este
/// widget nunca chega a ser aberto pelo usuário.
///
/// O arquivo existe para que os 12 acontecimentos tenham cada um o seu lugar
/// — quando a captura chegar, ela entra aqui, como `PhotoInput` +
/// `QuickLogFormWidget`, sem mexer em mais nada.
class PhotoForm extends StatelessWidget {
  const PhotoForm({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

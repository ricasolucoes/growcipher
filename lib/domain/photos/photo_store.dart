import 'dart:typed_data';

/// Armazenamento privado de fotos (ocultas da galeria do sistema, EXIF
/// removido, sem upload).
///
/// A implementação chega na fase "Fotos e privacidade" do roadmap; o domínio
/// referencia fotos apenas por um `photoRef` opaco emitido por este contrato,
/// para que nenhuma tela dependa de detalhes de arquivo ou de rede.
abstract class PhotoStore {
  /// Armazena a foto e devolve o `photoRef` para associar a plantas/eventos.
  Future<String> savePhoto(String tempPath);

  /// Caminho da foto, ou `null` se a referência não existir mais.
  Future<String?> getPhotoPath(String photoRef);

  Future<List<String>> getAllPhotos();

  Future<void> deletePhoto(String photoRef);
}

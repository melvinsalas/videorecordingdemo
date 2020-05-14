import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Declaración de variables

  List<CameraDescription> _cameras; // Lista de cámaras disponibles
  CameraController _controller; // Controlador de la cámara
  int _cameraIndex; // Índice de cámara actual
  bool _isRecording = false; // Bandera indicadora de grabación en proceso
  String _filePath; // Dirección del archivo grabado

  @override
  void initState() {
    super.initState();
    // Verificar la lista de cámaras disponibles al iniciar el Widget
    availableCameras().then((cameras) {
      // Guardar la lista de cámaras
      _cameras = cameras;
      // Inicializar la cámara solo si la lista de cámaras tiene cámaras disponibles
      if (_cameras.length != 0) {
        // Inicializar el índice de cámara actual en 0 para obtener la primera
        _cameraIndex = 0;
        // Inicializar la cámara pasando el CameraDescription de la cámara seleccionada
        _initCamera(_cameras[_cameraIndex]);
      }
    });
  }

  // Inicializar la cámara
  _initCamera(CameraDescription camera) async {
    // Si el controlador está en uso,
    // realizar un dispose para detenerlo antes de continuar
    if (_controller != null) await _controller.dispose();
    // Indicar al controlador la nueva cámara a utilizar
    _controller = CameraController(camera, ResolutionPreset.medium);
    // Agregar un Listener para refrescar la pantalla en cada cambio
    _controller.addListener(() => this.setState(() {}));
    // Inicializar el controlador
    _controller.initialize();
  }

  // Crear el Widget con la visualización del cámara
  Widget _buildCamera() {
    // Si el controlador es nulo o no está inicializado aún,
    // desplegar un mensaje al usuario y evitar mostrar una cámara sin inicializar
    if (_controller == null || !_controller.value.isInitialized)
      return Center(child: Text('Loading...'));
    // Utilizar un Widget de tipo AspectRatio para desplegar el alto y ancho correcto
    return AspectRatio(
      // Solicitar la relación alto/ancho al controlador
      aspectRatio: _controller.value.aspectRatio,
      // Mostrar el contenido del controlador mediante el Widget CameraPreview
      child: CameraPreview(_controller),
    );
  }

  // Crear los controles que permiten la interacción del video
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // Ícono para cambiar la cámara
        IconButton(
          icon: Icon(_getCameraIcon(_cameras[_cameraIndex].lensDirection)),
          onPressed: _onSwitchCamera,
        ),
        // Ícono para iniciar la grabación
        IconButton(
          icon: Icon(Icons.radio_button_checked),
          onPressed: _isRecording ? null : _onRecord,
        ),
        // Ícono para tener la grabación
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: _isRecording ? _onStop : null,
        ),
        // Ícono para reproducir el video grabado
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: _isRecording ? null : _onPlay,
        ),
      ],
    );
  }

  // Abrir el archivo último video grabado
  void _onPlay() => OpenFile.open(_filePath);

  // Detener la grabación de video
  Future<void> _onStop() async {
    // Utilizar el controlador para detener la grabación
    await _controller.stopVideoRecording();
    // Actualizar la bandera de grabación
    setState(() => _isRecording = false);
  }

  // Iniciar la grabación de video
  Future<void> _onRecord() async {
    // Obtener la dirección temporal
    var directory = await getTemporaryDirectory();
    // Añadir el nombre del archivo a la dirección temporal
    _filePath = directory.path + '/${DateTime.now()}.mp4';
    // Utilizar el controlador para iniciar la grabación
    _controller.startVideoRecording(_filePath);
    // Actualizar la bandera de grabación
    setState(() => _isRecording = true);
  }

  // Retornar el ícono de la cámara
  IconData _getCameraIcon(CameraLensDirection lensDirection) {
    // Sí la cámara actual es la trasera,
    // mostrar el ícono de cámara delantera,
    // sino el ícono de cámara trasera
    return lensDirection == CameraLensDirection.back
        ? Icons.camera_front
        : Icons.camera_rear;
  }

  // Cambia la cámara actual
  void _onSwitchCamera() {
    // Si la cantidad de cámaras es 1 o inferior,
    // no hacer el cambio
    if (_cameras.length < 2) return;
    // Cambiar 1 por 0 ó 0 por 1
    _cameraIndex = (_cameraIndex + 1) % 2;
    // Inicializar la cámara pasando el CameraDescription de la cámara seleccionada
    _initCamera(_cameras[_cameraIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video recording with Flutter')),
      body: Column(children: [
        Container(height: 500, child: Center(child: _buildCamera())),
        _buildControls(),
      ]),
    );
  }
}

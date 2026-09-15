package mx.ipn.escom.camaramic.android

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import kotlinx.coroutines.launch
import mx.ipn.escom.camaramic.AppThemeOption
import mx.ipn.escom.camaramic.MediaItem

class MainActivity : ComponentActivity() {
    private val viewModel: AppViewModel by viewModels()
    private var onPermissionResult: ((Boolean) -> Unit)? = null

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { granted -> onPermissionResult?.invoke(granted) }

    fun requestPermission(permission: String, callback: (Boolean) -> Unit) {
        if (checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
            callback(true)
            return
        }
        onPermissionResult = callback
        permissionLauncher.launch(permission)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val theme by viewModel.theme.collectAsState()
            MaterialTheme(colorScheme = appColorScheme(theme)) {
                Surface(modifier = Modifier.fillMaxSize()) {
                    RootScreen(viewModel, activity = this)
                }
            }
        }
    }
}

@Composable
private fun appColorScheme(theme: AppThemeOption): ColorScheme {
    val seed = Color(theme.argb)
    return if (isSystemInDarkTheme()) {
        darkColorScheme(primary = seed)
    } else {
        lightColorScheme(primary = seed)
    }
}

@Composable
fun RootScreen(viewModel: AppViewModel, activity: MainActivity) {
    var selectedTab by remember { mutableStateOf(0) }

    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    icon = { Icon(Icons.Default.CameraAlt, contentDescription = null) },
                    label = { Text("Cámara") },
                )
                NavigationBarItem(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    icon = { Icon(Icons.Default.Mic, contentDescription = null) },
                    label = { Text("Micrófono") },
                )
                NavigationBarItem(
                    selected = selectedTab == 2,
                    onClick = { selectedTab = 2 },
                    icon = { Icon(Icons.Default.PhotoLibrary, contentDescription = null) },
                    label = { Text("Galería") },
                )
            }
        },
    ) { padding ->
        Box(modifier = Modifier.padding(padding).fillMaxSize()) {
            when (selectedTab) {
                0 -> CameraScreen(viewModel, activity)
                1 -> AudioScreen(viewModel, activity)
                else -> GalleryScreen(viewModel)
            }
        }
    }
}

@Composable
fun CameraScreen(viewModel: AppViewModel, activity: MainActivity) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val scope = rememberCoroutineScope()

    var hasPermission by remember { mutableStateOf(false) }
    var category by remember { mutableStateOf("General") }
    var imageCapture by remember { mutableStateOf<ImageCapture?>(null) }

    LaunchedEffect(Unit) {
        activity.requestPermission(Manifest.permission.CAMERA) { granted -> hasPermission = granted }
    }

    if (!viewModel.camera.isAvailable) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Este dispositivo no reporta una cámara disponible.")
        }
        return
    }

    if (!hasPermission) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Se necesita permiso de cámara.")
        }
        return
    }

    Column(Modifier.fillMaxSize()) {
        AndroidView(
            modifier = Modifier.weight(1f).fillMaxWidth(),
            factory = { ctx ->
                val previewView = PreviewView(ctx)
                val providerFuture = ProcessCameraProvider.getInstance(ctx)
                providerFuture.addListener({
                    val provider = providerFuture.get()
                    val preview = Preview.Builder().build().also {
                        it.surfaceProvider = previewView.surfaceProvider
                    }
                    val capture = ImageCapture.Builder().build()
                    provider.unbindAll()
                    provider.bindToLifecycle(lifecycleOwner, CameraSelector.DEFAULT_BACK_CAMERA, preview, capture)
                    imageCapture = capture
                }, androidx.core.content.ContextCompat.getMainExecutor(ctx))
                previewView
            },
        )
        OutlinedTextField(
            value = category,
            onValueChange = { category = it },
            label = { Text("Categoría") },
            modifier = Modifier.fillMaxWidth().padding(8.dp),
        )
        Button(
            onClick = {
                val capture = imageCapture ?: return@Button
                scope.launch {
                    val bytes = viewModel.camera.capturePhoto(capture)
                    if (bytes != null) viewModel.savePhoto(bytes, category)
                }
            },
            modifier = Modifier.fillMaxWidth().padding(16.dp),
        ) {
            Text("Capturar foto")
        }
    }
}

@Composable
fun AudioScreen(viewModel: AppViewModel, activity: MainActivity) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var hasPermission by remember { mutableStateOf(false) }
    var category by remember { mutableStateOf("General") }

    LaunchedEffect(Unit) {
        activity.requestPermission(Manifest.permission.RECORD_AUDIO) { granted -> hasPermission = granted }
    }

    val isRecording by viewModel.audio.isRecording.collectAsState()
    val level by viewModel.audio.levelMeter.collectAsState()
    val elapsed by viewModel.audio.elapsedSeconds.collectAsState()

    Column(
        Modifier.fillMaxSize().padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        LinearProgressIndicator(progress = { level }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(16.dp))
        Text("%.0fs".format(elapsed), style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(
            value = category,
            onValueChange = { category = it },
            label = { Text("Categoría") },
            modifier = Modifier.fillMaxWidth(),
        )
        Spacer(Modifier.height(16.dp))
        Button(
            enabled = hasPermission,
            onClick = {
                scope.launch {
                    if (isRecording) {
                        val bytes = viewModel.audio.stop()
                        if (bytes != null) viewModel.saveAudioRecording(bytes, category, elapsed)
                    } else {
                        viewModel.audio.start(context)
                    }
                }
            },
        ) {
            Text(if (isRecording) "Detener grabación" else "Grabar")
        }
    }
}

@Composable
fun GalleryScreen(viewModel: AppViewModel) {
    val mediaItems by viewModel.repository.items.collectAsState()

    if (mediaItems.isEmpty()) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Sin contenido capturado todavía")
        }
        return
    }
    LazyColumn {
        items(mediaItems) { item: MediaItem ->
            ListItem(
                headlineContent = { Text(item.fileName) },
                supportingContent = { Text(item.category) },
                trailingContent = {
                    IconButton(onClick = { viewModel.deleteItem(item) }) {
                        Icon(Icons.Default.Delete, contentDescription = "Eliminar")
                    }
                },
            )
            Divider()
        }
    }
}

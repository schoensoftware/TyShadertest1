

# Advanced Ice Shader for Unity URP

This Unity project demonstrates an advanced ice shader for the Universal Render Pipeline (URP) with realistic effects including refraction, reflection, and proper transparency handling.

## Getting Started

### Prerequisites
- Unity 2019.4 or later with Universal Render Pipeline (URP)
- Basic knowledge of Unity editor

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/schoensoftware/TyShadertest1.git
   ```

2. **Open in Unity**:
   - Open Unity Hub
   - Click "Add project from disk" and select the cloned folder
   - Make sure to open it as a URP project

## Using the Ice Shader

### Quick Start

1. Open `Assets/Scenes/IceDemo.unity`
2. Press Play in the Unity editor
3. You should see multiple ice blocks with realistic effects

### Customizing the Shader

1. **Create a new material**:
   - Right-click in the Project window > Create > Material
   - Select "AdvancedIceShader" from the shader dropdown

2. **Adjust properties**:
   - **Base Color**: Change the color and transparency of the ice
   - **Refraction Strength**: Controls how much light bends through the ice
   - **Reflection Strength**: Adjusts reflectiveness
   - **Fresnel Power**: Controls edge highlights

3. **Apply to objects**:
   - Drag the material onto any 3D object in your scene

### Adding Normal Maps (Optional)

For more detailed surface effects:
1. Create a normal map texture
2. Assign it to the material's `_NormalMap` property
3. The shader will automatically use it for added detail

## Testing and Development

### Running Tests

The project includes test scripts that demonstrate the shader's capabilities:
- `Assets/Scripts/IceShaderDemo.cs`: Main demo script that creates ice blocks when run
- `Assets/Scenes/IceDemo.unity`: Scene set up to showcase the shader

### Making Changes

1. **Create a new branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes** in Unity or with text editors

3. **Commit and push**:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin feature/my-new-feature
   ```

## Shader Features

The `AdvancedIceShader.shader` includes:
- **Refraction**: Light bending through transparent surfaces
- **Reflection**: Realistic reflections based on viewing angle
- **Fresnel Effect**: More reflection at grazing angles
- **Transparency**: Proper alpha handling for realistic ice appearance

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by real-world ice physics and lighting behavior
- Built using Unity's Universal Render Pipeline (URP)

---

Happy shading! 🧊✨


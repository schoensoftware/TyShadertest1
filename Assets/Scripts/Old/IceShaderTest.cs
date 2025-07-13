


using UnityEngine;

public class IceShaderTest : MonoBehaviour
{
    public GameObject iceBlockPrefab;
    public Material iceMaterial;

    void Start()
    {
        // Create the material if it doesn't exist
        if (iceMaterial == null)
        {
            Shader shader = Shader.Find("Custom/AdvancedIceShader");
            if (shader != null)
            {
                iceMaterial = new Material(shader);
                Debug.Log("Created ice material using custom shader.");
            }
            else
            {
                Debug.LogError("Could not find shader: Custom/AdvancedIceShader");
                return;
            }
        }

        // Create an ice block if no prefab is provided
        if (iceBlockPrefab == null)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.name = "IceBlock";
            iceBlockPrefab = cube;
        }

        // Set up the camera if none exists
        if (Camera.main == null)
        {
            GameObject cameraObj = new GameObject("Main Camera");
            Camera camera = cameraObj.AddComponent<Camera>();
            camera.transform.position = new Vector3(0, 2, -5);
            camera.transform.rotation = Quaternion.Euler(15, 0, 0);
        }

        // Create multiple ice blocks to demonstrate the shader
        for (int i = -1; i <= 1; i++)
        {
            for (int j = -1; j <= 1; j++)
            {
                GameObject block = Instantiate(iceBlockPrefab);
                block.transform.position = new Vector3(i * 2, j * 2, 0);
                block.GetComponent<Renderer>().material = iceMaterial;

                // Add a light to show refraction effects
                if (i == 0 && j == 0)
                {
                    GameObject lightObj = new GameObject("DirectionalLight");
                    Light light = lightObj.AddComponent<Light>();
                    light.type = LightType.Directional;
                    light.transform.rotation = Quaternion.Euler(45, 30, 0);
                }
            }
        }

        Debug.Log("Ice shader test setup complete!");
    }
}



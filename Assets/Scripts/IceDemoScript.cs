




using UnityEngine;

public class IceDemoScript : MonoBehaviour
{
    void Start()
    {
        // Create the material using our fixed shader
        Shader shader = Shader.Find("Custom/FixedAdvancedIceShader");
        if (shader != null)
        {
            Material iceMaterial = new Material(shader);

            // Set some properties for better visuals
            iceMaterial.SetColor("_BaseColor", new Color(0.8f, 0.9f, 1.0f, 0.7f));
            iceMaterial.SetFloat("_RefractionStrength", 0.3f);
            iceMaterial.SetFloat("_ReflectionStrength", 0.6f);
            iceMaterial.SetFloat("_FresnelPower", 2.5f);

            // Create multiple ice blocks
            for (int i = -1; i <= 1; i++)
            {
                for (int j = -1; j <= 1; j++)
                {
                    GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                    cube.transform.position = new Vector3(i * 2, j * 2, 0);
                    cube.transform.localScale = Vector3.one * 1.5f;
                    cube.GetComponent<Renderer>().material = iceMaterial;

                    // Rotate some blocks for better viewing angles
                    if (i != 0 || j != 0)
                    {
                        cube.transform.rotation = Quaternion.Euler(0, 45, 0);
                    }
                }
            }

            // Set up lighting
            if (RenderSettings.sun == null)
            {
                GameObject sun = new GameObject("Sun");
                Light sunLight = sun.AddComponent<Light>();
                sunLight.type = LightType.Directional;
                sunLight.color = Color.white;
                sunLight.intensity = 1.2f;
                sunLight.transform.rotation = Quaternion.Euler(45, 30, 0);
            }

            // Set up camera
            if (Camera.main == null)
            {
                GameObject cameraObj = new GameObject("Main Camera");
                Camera camera = cameraObj.AddComponent<Camera>();
                camera.transform.position = new Vector3(0, 2.5f, -7);
                camera.transform.rotation = Quaternion.Euler(15, 0, 0);
            }

            Debug.Log("Ice shader demo setup complete!");
        }
        else
        {
            Debug.LogError("Could not find shader: Custom/FixedAdvancedIceShader");
        }
    }
}






using UnityEngine;

public class MainTestScript : MonoBehaviour
{
    void Start()
    {
        // Create a new material using our custom shader
        Shader shader = Shader.Find("Custom/BasicUnlitShader");
        if (shader != null)
        {
            Material material = new Material(shader);

            // Set the color property
            material.SetColor("_Color", Color.blue);

            // Create a cube and apply the material
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.GetComponent<Renderer>().material = material;

            // Position the cube in front of the camera
            cube.transform.position = new Vector3(0, 0, 5);

            Debug.Log("Shader test successful! Created a blue cube.");
        }
        else
        {
            Debug.LogError("Could not find shader: Custom/BasicUnlitShader");
        }

        // Create a main camera if none exists
        if (Camera.main == null)
        {
            GameObject cameraObj = new GameObject("Main Camera");
            cameraObj.AddComponent<Camera>();
            cameraObj.transform.position = new Vector3(0, 0, -10);
        }
    }
}


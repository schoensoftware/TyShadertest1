


using UnityEngine;

public class MainIceDemo : MonoBehaviour
{
    void Start()
    {
        // Add the demo script to this game object
        IceShaderDemo demo = gameObject.AddComponent<IceShaderDemo>();

        Debug.Log("Ice shader demo started!");
    }
}



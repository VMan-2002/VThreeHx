# VThreeHx

ThreeJs port to HaxeFlixel

Testing project: [VThreeHxTest](https://github.com/VMan-2002/VThreeHxTest)

Based on ThreeJs version [r176](https://github.com/mrdoob/three.js/tree/r176)

## Progress

~~literally just starting out, implementing as i go~~
Current objective: WebGLRenderer

checkmarks do not mean it's fully working

Required for example scene
- Constants✅
- Scene✅
    - Object3D✅
        - Quaternion✅
            - MathUtils✅
        - Vector3✅
        - Matrix4✅
        - EventDispatcher✅
        - Euler✅
        - Layers✅
        - Matrix3✅
- PerspectiveCamera✅
    - Camera✅
    - Vector2✅
- BoxGeometry✅
    - BufferGeometry✅
        - Box3✅
        - BufferAttribute✅
            - DataUtils✅
        - Sphere✅
- MeshBasicMaterial✅
    - Material✅
        - Texture✅
            - Source✅
                - ImageUtils❌ (Should not be necessary in haxe, i think)
    - Color✅
        - ColorManagement✅
- Mesh✅
    - Ray✅
        - Plane✅
            - Line3✅
    - Triangle✅
        - Vector4✅
    - Raycaster✅
- WebGLRenderer //the boss fight
    - Frustum

Welcome to [TypedArray](https://github.com/VMan-2002/VThreeHx/blob/main/vman2002/vthreehx/TypedArray.hx), the worst hx file

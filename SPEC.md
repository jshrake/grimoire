# File Format and Runtime Behavior

```glsl
// TOML CONFIGURATION IN THE FIRST BLOCK COMMENT OF THE FILE
/*
# INPUTS
[cat]
image = "cat.png"

[dog]
image = "poodle.png"

[mic]
microphone = true

# PASS 0
[[pass]]
iChannel0 = "cat"
iChannel1 = "dog"

# PASS 1
[[pass]]
iChannel0 = {pass = 0}
iChannel1 = "mic"
*/
// YOUR GLSL CODE
#ifdef GRIM_PASS_0
void mainImage(out vec4 fragColor, in vec2 fragCoord) {..}
#endif
#ifdef GRIM_PASS_1
void mainImage(out vec4 fragColor, in vec2 fragCoord) {..}
#endif
```

The only required input to grimoire is a single [GLSL](https://en.wikipedia.org/wiki/OpenGL_Shading_Language) file with [TOML](https://github.com/toml-lang/toml) configuration embedded in a comment block. This document describes the configuration format and the GLSL code grimoire inserts into your shader before compilation.

- [Configuration](#configuration)
    - [Inputs](#inputs)
    - [Passes](#passes)
- [GLSL](#glsl)
    - [Vertex shader](#fragment)
    - [Fragment shader](#vertex)


# Configuration

```toml
# INPUTS
[cat]
image = "cat.png"

[dog]
image = "poodle.png"

[mic]
microphone = true

# PASS 0
[[pass]]
iChannel0 = "cat"
iChannel1 = "dog"

# PASS 1
[[pass]]
iChannel0 = {pass = 0}
iChannel1 = "mic"
```

The configuration defines named texture inputs and an ordered list of rendering passes. The pass configuration associates sampler uniform names with texture inputs for use in your shader code. The pass configuration also allows users to set framebuffer properties, vertex count, blending, depth testing, and the clear color. By convention, we define inputs above the list of passes.

## Inputs

An input is a [TOML table](https://github.com/toml-lang/toml#user-content-table) that configures a texture object. The input name is the table name, and pass configurations reference this name to associate a uniform sampler with the input texture. Below is a list of all supported inputs with key-value information. Note that all relative paths are relative to the shader input file.

### Image
- **image=string**: Required, relative path to an image file. Supports [png, jpeg, gif, bmp, ico, tiff, webp, pnm](https://github.com/PistonDevelopers/image#21-supported-image-formats)
- **flipv=bool**: Optional, flip the image vertically before uploading to the GPU, defaults to true
- **fliph=bool**: Optional, flip the image horizontally before uploading to the GPU, defaults to false

### Cubemap
- **left=string**: Required, relative path to an image file for the left cubemap face
- **right=string**: Required, relative path to an image file for the right cubemap face
- **front=string**: Required, relative path to an image file for the front cubemap face
- **back=string**: Required, relative path to an image file for the back cubemap face
- **top=string**: Required, relative path to an image file for the top cubemap face
- **bottom=string**: Required, relative path to an image file for the bottom cubemap face
- **flipv=bool**: Optional, flip the image vertically before uploading to the GPU, defaults to true
- **fliph=bool**: Optional, flip the image horizontally before uploading to the GPU, defaults to false

Each face supports the same file formats at the image input.

### Texture2D
- **texture2D=string**: Required, relative path to a file containing 2D texture data
- **width=u32**: Required, the texture width
- **height=u32**: Required, the texture height
- **format=u8**: Required, the texture format, accepts the following strings: "rU8", "rf16", "rf32", "rgu8", "rgf16", "rgf32", "rgbu8", "rgbf16", "rgbf32", "rgbau8", "rgbaf16", "rgbaf32", "bgru8", "bgrf16", "bgrf32", "bgrau8", "bgraf16", "bgraf32"

### Texture3D
- **texture3D=string**: Required, relative path to a file containing 3D texture data
- **width=u32**: Required, the texture width
- **height=u32**: Required, the texture height
- **depth=u32**: Required, the texture depth
- **format=u8**: Required, the texture format, accepts the following strings: "rU8", "rf16", "rf32", "rgu8", "rgf16", "rgf32", "rgbu8", "rgbf16", "rgbf32", "rgbau8", "rgbaf16", "rgbaf32", "bgru8", "bgrf16", "bgrf32", "bgrau8", "bgraf16", "bgraf32"

### Keyboard
- **keyboard=bool**: Required, the value is ignored.

### Webcam
- **webcam=bool**: Required, the value is ignored.

### Microphone
- **microphone=bool**: Required, the value is ignored.

### Video
- **video=string**: Required, relative path to a video file OR a uri. File support depends on your GStreamer installation. A wrapper around [playbin](https://gstreamer.freedesktop.org/data/doc/gstreamer/head/gst-plugins-base-plugins/html/gst-plugins-base-plugins-playbin.html). Users can use `playbin2` and `playbin3` by defining the enviornment variables `USE_PLAYBIN2=1 ` and `USE_PLAYBIN3=1 `, respectively.

### Audio
- **audio=string**: Required, relative path to an audio file OR a uri. File support depends on your GStreamer installation. A wrapper around [uridecodebin](https://gstreamer.freedesktop.org/data/doc/gstreamer/head/gst-plugins-base-plugins/html/gst-plugins-base-plugins-uridecodebin.html)

### Pipeline
- **pipeline=string**: Required, a GStreamer [gst-launch pipeline description](https://gstreamer.freedesktop.org/documentation/tools/gst-launch.html). grimoire assumes that the pipeline description contains an appsink element with name appsink and that the pipeline produces samples with video caps.

## Passes

Passes are defined as an [array of tables](https://github.com/toml-lang/toml#array-of-tables) and are drawn in the order listed in the configuration. A pass has the following optional set of key-values:

- **buffer={width=u32, height=u32, attachments=u32, format=string{"u8", "f16", "f32"}}**: configures the framebuffer for the pass, defaults to width=window width, height=window height, attachments=1, format="f32"
- **draw={mode=string{"triangles", "points", ...}, count=u32}**: configures the draw primitive and number of vertices to emit from the draw call, defaults to mode="triangles", count=1, [full list of valid strings](https://github.com/jshrake/grimoire/blob/master/src/config.rs#L171-L187)
- **depth=string{"less",...}**: depth testing, defaults to disabled, [full list of valid strings](https://github.com/jshrake/grimoire/blob/master/src/config.rs#L121-L139)
- **blend={src=string{"one",..}, dest=string{"one-minus-src-alpha",..}}**: blend functions, defaults to disabled [full list of valid strings](https://github.com/jshrake/grimoire/blob/master/src/config.rs#L147-L169)
- **clear=[f32;4]**: configures the clear color for the pass, defaults to [0.0, 0.0, 0.0, 1.0]

All other key-value pairs are treated as an association between a desired uniform sampler name that you use in your shader, and a texture resource. The key name is used as the name of the uniform sampler declaration. The value is required to specify either an index to a pass or the name of an input, and optionally the color attachment for a pass and the properties of the texture sampling, such as the wrap and filter. The accepted values are:

**samplerName=string**: a resource name, references a named input table defined in the configuration
**samplerName=u32**: a resource name, references a named input table defined in the configuration
**samplerName={pass=u32, attachment=u32, wrap="clamp","repeat", filter="linear","nearest"}**: requires pass, defaults to attachment=0, wrap="repeat", filter="linear" 
**samplerName={resource=string, wrap="clamp","repeat", filter="linear","nearest"}**: requires resource, defaults towrap="repeat", filter="linear" |

### Uniform Insertion

For each NAME=VAL in pass, grimoire inserts the following uniform declarations into your shader code before compiling it for that pass:

- `uniform SAMPLERTYPE_FROM_VAL NAME`: The texture sampler
- `uniform vec3 NAME_Resolution`: The resolution of the texure resource, z contains the aspect ratio
- `uniform float NAME_Time`: The playback time  of the texture resource

By convention, you should use the key names `iChannel0`, `iChannel1`, ... `iChannelN` in your configuration to make your shader easier to paste into shadertoy.

# GLSL

```glsl
...
#ifdef GRIM_PASS_0
void mainImage(out vec4 fragColor, in vec2 fragCoord) {..}
#endif

#ifdef GRIM_PASS_1
void mainImage(out vec4 fragColor, in vec2 fragCoord) {..}
#endif
```

Your GLSL code defines the vertex and fragment shader main function for all the passes. grimorie inserts additional code above and below your GLSL code before compiling the vertex and fragment shader for each pass. [Default main definitions](./src/default_shader_footer.glsl) are inserted for both the vertex and fragment shader. The default vertex shader positions a full-screen quad, and the default fragment shader is the shadertoy image shader and expects the user to define `void mainImage(out vec4 fragColor, in vec2 fragCoord)`. You can disable the default main definition for your pass by specifying `#define GRIM_OVERRIDE_MAIN` in your code.

## Fragment

The fragment shader for each pass is generated by concatenating the following list of strings:

- A `#version` statement appropriate for the `gl` argument passed at the command-line
- `#define GRIM_FRAGMENT`
- `#define GRIM_FRAGMENT_PASS_%d`, where `%d` is the zero-based index of the pass under compilation
- `#define GRIM_PASS_%d`, equivalent to `GRIM_FRAGMENT_PASS_%d`
- Default uniform declarations available to all passes, see [header.glsl](./src/header.glsl)
- Uniform sampler declarations generated from the pass configuration, see [uniform insertion](#uniform-insertion)
- `#line 1 0`
- Your shader code
- Default main definitions, see [footer.glsl](./src/footer.glsl). Disable by specifying `#define GRIM_OVERRIDE MAIN`

### Useful patterns

- A single pass shader requires no GLSL preprocessor directives

```glsl
...
void mainImage (out vec4 fragColor, in vec2 fragCoord) {
    ...
}
```

- Mutli-pass shaders need to isolate `mainImage` definitions in `#ifdef GRIM_PASS_%d` blocks

```glsl
...
#ifdef GRIM_PASS_0
void mainImage (out vec4 fragColor, in vec2 fragCoord) {
}
#endif
#ifdef GRIM_PASS_1
void mainImage (out vec4 fragColor, in vec2 fragCoord) {
}
#endif
```

- [Writing to multiple render targets in a single pass, and referencing each target in another pass](https://github.com/jshrake/grimoire-examples/blob/master/multiple-render-targets.glsl)

## Vertex

The vertex shader for each pass is generated by concatenating the following list of strings:

- A `#version` statement appropriate for the `gl` argument passed at the command-line
- `#define GRIM_VERTEX`
- `#define GRIM_VERTEX_PASS_%d`, where `%d` is the zero-based index of the pass under compilation
- Default uniform declarations available to all passes, see [header.glsl](./src/header.glsl)
- Uniform sampler declarations generated from the pass configuration, see [uniform insertion](#uniform-insertion)
- `#line 1 0`
- Your shader code
- Default main definitions, see [footer.glsl](./src/footer.glsl). Disable by specifying `#define GRIM_OVERRIDE MAIN`

### Useful patterns

- Override the default vertex shader for all passes:

```glsl
...
#ifdef GRIM_VERTEX
#define GRIM_OVERRIDE_MAIN
void main() {...}
#endif
...
```

- Override the default vertex shader of a specific pass:

```glsl
...
#ifdef GRIM_VERTEX_PASS_%d
#define GRIM_OVERRIDE_MAIN
void main() {...}
#endif
...
```

- Override the default vertex shader for all passes and further override a specific pass:

```glsl
...
#ifdef GRIM_VERTEX_PASS_%d
#define GRIM_OVERRIDE_MAIN
#define OVERRIDE_OUR_DEFAULT
void main() {...}
#endif
...
#if defined(GRIM_VERTEX) && !defined(OVERRIDE_OUR_DEFAULT)
#define GRIM_OVERRIDE_MAIN
void main() {...}
#endif
...
```

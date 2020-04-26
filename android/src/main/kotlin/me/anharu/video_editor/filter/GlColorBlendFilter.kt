package me.anharu.video_editor.filter

import com.daasuu.mp4compose.filter.GlFilter;
import android.opengl.GLES20
import me.anharu.video_editor.Filter


class GlColorBlendFilter(filter: Filter) : GlFilter(GlFilter.DEFAULT_VERTEX_SHADER,this.CONTRAST_FRAGMENT_SHADER) {
    private val filter: Filter = filter;
    companion object {
        const val CONTRAST_FRAGMENT_SHADER =
                """
                precision mediump float;
                varying vec2 vTextureCoord;
                uniform lowp sampler2D sTexture;
                uniform lowp float red;
                uniform lowp float green;
                uniform lowp float blue;
                    void main() {
                       vec4 color = vec4(red,green,blue,0.1);
                       gl_FragColor = mix(texture2D(sTexture, vTextureCoord), color, 0.5);
                    }
                """
    }

    public override fun onDraw() {
        when (filter.type) {
            0 -> {
                GLES20.glUniform1f(getHandle("red"), 1f)
                GLES20.glUniform1f(getHandle("green"), 192f/255f)
                GLES20.glUniform1f(getHandle("blue"), 203f/255f)

            }
            else -> {
                GLES20.glUniform1f(getHandle("red"), 1f)
                GLES20.glUniform1f(getHandle("green"), 192f/255f)
                GLES20.glUniform1f(getHandle("blue"), 203f/255f)
            }
        }

    }
}
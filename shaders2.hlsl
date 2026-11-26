struct VSInput
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

struct PSInput
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

Texture2D g_texture : register(t0);
SamplerState g_sampler : register(s0);

cbuffer Params : register(b0)
{
    float angle;
    float aspect;
    float2 center;

    float time;
    float pulse;
    float scroll;
    float depth;  

    float frame;
    float cols;
    float rows;
    float pad2;
};

PSInput VSMain(VSInput input)
{
    PSInput result;

    float s, c;
    sincos(angle, s, c);

    float scale = 1.0f + pulse * sin(time * 4.0f);

    // вершины построены вокруг (0,0), Y в C++ уже умножен на aspect
    float2 p = float2(input.position.x, input.position.y / max(aspect, 0.0001f)) * scale;

    float2 rotated;
    rotated.x = p.x * c - p.y * s;
    rotated.y = p.x * s + p.y * c;

    // сдвиг на центр фигуры, потом коррекция пропорций
   result.position = float4(rotated.x + center.x,
                         (rotated.y + center.y) * aspect,
                         depth,
                         1.0f);

    result.uv = input.uv;
    result.color = input.color;
    return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    float2 uv = input.uv + float2(time * scroll, 0.0f);

    // выбор кадра из листа (при cols = rows = 1 ничего не меняется)
    float c = max(cols, 1.0f);
    float r = max(rows, 1.0f);
    float col = fmod(frame, c);
    float row = floor(frame / c);
    uv = (float2(col, row) + uv) / float2(c, r);

    return g_texture.Sample(g_sampler, uv) * input.color;
}
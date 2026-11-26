cbuffer Params : register(b0)
{
    float4x4 mvp;
    float4x4 world;
    float time;
    float pulse;
    float mode;
    float pad;
    float4 lightDir;
    float4 camPos;
};

struct VSInput
{
    float3 position : POSITION;
    float4 color : COLOR;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct PSInput
{
    float4 position : SV_POSITION;
    float4 color : COLOR;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

PSInput VSMain(VSInput i)
{
    PSInput o;

    float scale = 1.0f + pulse * sin(time * 4.0f);
    float3 p = i.position * scale;

    float4 localPos = float4(p, 1.0f);

    // DirectXMath: вектор умножается на матрицу
    float4 wp = mul(localPos, world);

    o.position = mul(localPos, mvp);
    o.worldPos = wp.xyz;

    o.normal = normalize(mul(i.normal, (float3x3)world));

    o.color = i.color;
    o.uv = i.uv;

    return o;
}
float4 PSMain(PSInput i) : SV_TARGET
{
    // Частицы и свечение
    if (mode > 0.5f)
    {
        float d = length(i.uv * 2.0f - 1.0f);
        float b = saturate(1.0f - d);
        b *= b;

        return float4(i.color.rgb, i.color.a * b);
    }

    float3 N = normalize(i.normal);

    // Направление света
    float3 L = normalize(-lightDir.xyz);

    // Направление камеры
    float3 V = normalize(camPos.xyz - i.worldPos);

    // Полувектор
    float3 H = normalize(L + V);

    // Освещение
    float diff = saturate(dot(N, L));

    // Блик
    float spec = 0.0f;

    if (diff > 0.0f)
        spec = pow(saturate(dot(N, H)), 32.0f);

    float3 ambient = i.color.rgb * 0.15f;
    float3 diffuse = i.color.rgb * diff * 0.85f;
    float3 specular = spec * 0.5f;

    return float4(ambient + diffuse + specular, 1.0f);
}
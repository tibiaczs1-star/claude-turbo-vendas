from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import os

src_img = Image.open(r'C:\Users\junio\.gemini\antigravity\brain\5f55f73c-60b4-4cb3-a310-06405054e9d1\.user_uploaded\media_1794381697689_e914307a.png')
# Crop skull and brain area
crop_box = (6, 0, 130, 92)
sprite = src_img.crop(crop_box)

# Create a clean mask: the character consists of:
# 1) Pure black head/body outline (0, 0, 0)
# 2) White highlights, white eyes, nose, teeth, ribs (around >200)
# 3) Pink brain (R > 180, B > 120)
arr = np.array(sprite)
h, w, c = arr.shape
clean_arr = np.zeros((h, w, 4), dtype=np.uint8)

for y in range(h):
    for x in range(w):
        r, g, b, a = arr[y, x]
        # Pink brain
        if r > 160 and g < 150 and b > 110:
            clean_arr[y, x] = [r, g, b, 255]
        # White eyes/ribs/teeth
        elif r > 180 and g > 180 and b > 180:
            clean_arr[y, x] = [r, g, b, 255]
        # Black head / silhouette (only in the character silhouette)
        elif r < 40 and g < 40 and b < 40 and (x < 100 or (x < 125 and y > 35)):
            clean_arr[y, x] = [12, 12, 16, 255]
        # Outer space background / stars -> transparent
        else:
            clean_arr[y, x] = [0, 0, 0, 0]

char_sprite = Image.fromarray(clean_arr, mode='RGBA')

# Now let's create a 256x256 master icon:
# Style: Claude's iconic rounded-squircle robot silhouette with dark carbon background,
# subtle Claude terracotta/neon-cyan rim, and the skull+brain proudly in the center.
master = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
draw = ImageDraw.Draw(master)

# Background squircle (Claude robot head silhouette)
# Claude terracotta accent: #D97757 / #CC5500 & Cyber Cyan: #00D2FF
squircle_box = [16, 16, 240, 240]
# Draw glow
glow = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
glow_draw = ImageDraw.Draw(glow)
glow_draw.rounded_rectangle([12, 12, 244, 244], radius=48, fill=(0, 210, 255, 60))
glow_draw.rounded_rectangle([14, 14, 242, 242], radius=44, outline=(217, 119, 87, 180), width=3)
glow = glow.filter(ImageFilter.GaussianBlur(4))
master = Image.alpha_composite(master, glow)
draw = ImageDraw.Draw(master)

# Solid dark carbon squircle body
draw.rounded_rectangle(squircle_box, radius=42, fill=(13, 14, 19, 255), outline=(0, 210, 255, 200), width=3)

# Robot antenna/ears (Claude robot style) on top
draw.rectangle([118, 6, 138, 18], fill=(0, 210, 255, 255))
draw.ellipse([116, 2, 140, 12], fill=(217, 119, 87, 255))

# Scale character sprite to fit nicely inside
# Target height ~ 160px
scale = 160.0 / char_sprite.height
new_w = int(char_sprite.width * scale)
new_h = int(char_sprite.height * scale)
scaled_char = char_sprite.resize((new_w, new_h), Image.NEAREST)

# Center on the squircle
pos_x = (256 - new_w) // 2
pos_y = (256 - new_h) // 2 + 6
master.paste(scaled_char, (pos_x, pos_y), scaled_char)

# Save Master PNG
out_dir = r'C:\Users\junio\Downloads\JOGO\site-vendas\dist'
os.makedirs(out_dir, exist_ok=True)
png_path = os.path.join(out_dir, 'claudio_logo.png')
master.save(png_path, format='PNG')
print("Saved PNG logo to:", png_path)

# Also save to site-vendas assets & C:\claude
master.save(r'C:\claude\claudio_logo.png', format='PNG')
master.save(r'C:\Users\junio\Downloads\JOGO\site-vendas\claudio_logo.png', format='PNG')

# Generate Windows .ICO with multiple resolutions
ico_path = os.path.join(out_dir, 'claudio.ico')
master.save(ico_path, format='ICO', sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print("Saved ICO to:", ico_path)
master.save(r'C:\claude\claudio.ico', format='ICO', sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])

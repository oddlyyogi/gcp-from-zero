from PIL import Image, ImageDraw

img = Image.new("RGB", (600, 400), (20, 30, 70))
draw = ImageDraw.Draw(img)
draw.ellipse((380, 60, 520, 200), fill=(255, 160, 40))
draw.rectangle((0, 300, 600, 400), fill=(40, 120, 60))
img.save("samples/sunset.png")

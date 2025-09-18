from PIL import Image, ImageDraw, ImageFont
import os
import random

# Create assets directory structure
os.makedirs('assets/images', exist_ok=True)
os.makedirs('assets/images/fashion', exist_ok=True)
os.makedirs('assets/images/categories', exist_ok=True)
os.makedirs('assets/images/onboarding', exist_ok=True)

# Fashion color palette
fashion_colors = [
    (43, 43, 43),      # Charcoal
    (128, 128, 128),    # Gray
    (245, 245, 245),    # Off white
    (139, 69, 19),      # Saddle brown
    (25, 25, 112),      # Midnight blue
    (220, 20, 60),      # Crimson
    (75, 0, 130),       # Indigo
]

def create_gradient_image(width, height, colors, filename):
    """Create a gradient image with given colors"""
    image = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(image)
    
    # Create vertical gradient
    for y in range(height):
        ratio = y / height
        # Blend between first and last color
        r = int(colors[0][0] * (1 - ratio) + colors[-1][0] * ratio)
        g = int(colors[0][1] * (1 - ratio) + colors[-1][1] * ratio)
        b = int(colors[0][2] * (1 - ratio) + colors[-1][2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    image.save(filename, 'JPEG', quality=95)

def create_model_image(width, height, color_index, filename):
    """Create a model placeholder image"""
    color = fashion_colors[color_index % len(fashion_colors)]
    image = Image.new('RGB', (width, height), color)
    draw = ImageDraw.Draw(image)
    
    # Add a subtle pattern
    for i in range(0, width, 20):
        for j in range(0, height, 20):
            if (i + j) % 40 == 0:
                lighter_color = tuple(min(255, c + 15) for c in color)
                draw.rectangle([i, j, i+10, j+10], fill=lighter_color)
    
    # Add center circle for model silhouette
    center_x, center_y = width // 2, height // 2
    radius = min(width, height) // 4
    lighter = tuple(min(255, c + 30) for c in color)
    draw.ellipse([center_x - radius, center_y - radius, 
                  center_x + radius, center_y + radius], fill=lighter)
    
    image.save(filename, 'JPEG', quality=95)

def create_category_image(width, height, color_index, text, filename):
    """Create a category placeholder image with text"""
    color = fashion_colors[color_index % len(fashion_colors)]
    image = Image.new('RGB', (width, height), color)
    draw = ImageDraw.Draw(image)
    
    # Try to use a nice font, fallback to default
    try:
        font = ImageFont.truetype("arial.ttf", 40)
    except:
        font = ImageFont.load_default()
    
    # Add text in center
    text_color = (255, 255, 255) if sum(color) < 400 else (0, 0, 0)
    
    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (width - text_width) // 2
    y = (height - text_height) // 2
    
    draw.text((x, y), text, fill=text_color, font=font)
    
    image.save(filename, 'JPEG', quality=95)

# Create model images
model_names = ['model_0', 'model_1', 'model_2', 'model_3', 'model_4', 'model_5', 'model_6', 'model_7']
for i, name in enumerate(model_names):
    create_model_image(300, 400, i, f'assets/images/{name}.jpg')
    create_model_image(300, 400, i, f'assets/images/fashion/{name}.jpg')

# Create wishlist images
wishlist_names = ['wishlist_0', 'wishlist_1', 'wishlist_2']
for i, name in enumerate(wishlist_names):
    create_model_image(250, 350, i + 2, f'assets/images/{name}.jpg')

# Create main model image
create_model_image(400, 500, 0, 'assets/images/model.jpg')

# Create category images
categories = [
    ('dresses', 'DRESSES'),
    ('blazers', 'BLAZERS'), 
    ('accessories', 'ACCESSORIES'),
    ('dress', 'DRESS'),
    ('blazer', 'BLAZER')
]

for i, (filename, text) in enumerate(categories):
    create_category_image(300, 200, i + 1, text, f'assets/images/fashion/{filename}.jpg')

# Create item images
items = ['item1', 'item2', 'item3']
for i, name in enumerate(items):
    create_model_image(250, 300, i + 3, f'assets/images/{name}.jpg')

# Create onboarding images
onboarding_items = ['fashion_ai', 'virtual_tryons', 'personalized']
for i, name in enumerate(onboarding_items):
    create_gradient_image(400, 300, [fashion_colors[i], fashion_colors[i+1]], f'assets/images/onboarding/{name}.jpg')

print("✅ All fashion placeholder images created successfully!")
print("📁 Created in assets/images/ directory")
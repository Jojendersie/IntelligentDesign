import screenmanager;
import dsfml.graphics;
import species;
import std.stdio;

class GUI
{
	void render(RenderWindow window, const ScreenManager screenManager, const Species species)
	{
		auto rectangleShape = new RectangleShape();

		// right bar
		rectangleShape.fillColor = Color.Blue;
		rectangleShape.position = Vector2f(window.size.x - screenManager.geneBarWidth, 0);
		rectangleShape.size = Vector2f(screenManager.geneBarWidth, window.size.y);
		window.draw(rectangleShape);

		// lower bar
		rectangleShape.fillColor = Color.Cyan;
		rectangleShape.position = Vector2f(0, window.size.y - screenManager.lowerBarHeight);
		rectangleShape.size = Vector2f(window.size.x, screenManager.lowerBarHeight);
		window.draw(rectangleShape);

		// The genes
		foreach( gene; species.genes.keys )
		{
			const Species.GeneUsage* usage = &species.genes[gene];
			if( usage.num > 0 )
			{
				Sprite sprite = new Sprite(gene.texture());
				//writeln(usage.priority.x * (screenManager.geneBarWidth - 64) + 32 + screenManager.geneBarX);
				Vector2f pos;
				pos.x = usage.priority.x * (screenManager.geneBarWidth - 64) + screenManager.geneBarX;
				pos.y = usage.priority.y * (screenManager.geneBarHeight - 64);
				sprite.position = pos;
				sprite.scale = Vector2f(1.0f, 1.0f);
				window.draw(sprite);
			}
		}
	}
}
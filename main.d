import dsfml.graphics;
import game;
import std.datetime;
import core.thread;
import std.stdio;
import std.string;

immutable real timePerFrameSeconds = 1.0f / 60.0f;

void main(string[] args)
{
	auto window = new RenderWindow(VideoMode(1400, 768),"Intelligent Design!");
	auto game = new Game(window);
	StopWatch sw;

	// Can't hurt ;)
	window.setVerticalSyncEnabled(true);

	sw.start();
	while (window.isOpen())
	{
		sw.reset();

		Event event;
		while(window.pollEvent(event))
		{
			if(event.type == event.EventType.Closed)
			{
				window.close();
			}
			else if(event.type == event.EventType.Resized)
			{
				// overwrite the normal view behaviour - maybe the whole not-using-the-sfml-view was a bad idea...
				window.view = new View(FloatRect(0, 0, window.size.x, window.size.y));
			}
		}

		game.update(window);
			
		window.clear();
		game.render(window);

		window.display();

		real frameTimeSeconds = cast(real)sw.peek().length / TickDuration.ticksPerSec;
		if(frameTimeSeconds < timePerFrameSeconds)
		{
			core.thread.Thread.sleep(dur!("nsecs")(cast(long)((timePerFrameSeconds - frameTimeSeconds) * 1000000000)));
		}
		//writeln("Waiting ", (timePerFrameSeconds - frameTimeSeconds));
		writeln("fps ", 1.0 / frameTimeSeconds);
	}
}
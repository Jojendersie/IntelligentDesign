import dsfml.graphics;
import game;
import std.datetime;
import core.thread;
import std.stdio;
import std.string;

immutable real timePerFrameSeconds = 1.0f / 60.0f;

void main(string[] args)
{
    auto window = new RenderWindow(VideoMode(800,600),"Hello DSFML!");
	auto game = new Game();
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
        }

		game.update();
			
        window.clear();
		game.render(window);

        window.display();

		real frameTimeSeconds = cast(real)sw.peek().length / TickDuration.ticksPerSec;
		if(frameTimeSeconds < timePerFrameSeconds)
		{
			core.thread.Thread.sleep(dur!("nsecs")(cast(long)((timePerFrameSeconds - frameTimeSeconds) * 1000000000)));
		}
		//writeln("Waiting ", (timePerFrameSeconds - frameTimeSeconds));
    }
}
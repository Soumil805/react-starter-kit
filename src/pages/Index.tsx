import { Button } from "@/components/ui/button";
import { ArrowRight, Sparkles, Zap, Shield } from "lucide-react";

const Index = () => {
  return (
    <div className="min-h-screen bg-background">
      {/* Navigation */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-border/50">
        <nav className="container mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
              <Sparkles className="w-4 h-4 text-primary-foreground" />
            </div>
            <span className="font-display font-semibold text-lg">Starter</span>
          </div>
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm">Features</Button>
            <Button variant="ghost" size="sm">About</Button>
            <Button size="sm">Get Started</Button>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <main className="pt-32 pb-20">
        <section className="container mx-auto px-6">
          <div className="max-w-3xl mx-auto text-center animate-slide-up">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-secondary text-sm text-muted-foreground mb-8">
              <Sparkles className="w-4 h-4 text-accent" />
              <span>Welcome to your new project</span>
            </div>
            
            <h1 className="text-5xl md:text-6xl lg:text-7xl font-display font-bold text-foreground mb-6 text-balance">
              Build something{" "}
              <span className="text-accent">amazing</span> today
            </h1>
            
            <p className="text-lg md:text-xl text-muted-foreground mb-10 max-w-2xl mx-auto text-balance">
              A clean, modern React starter with beautiful design patterns. 
              Start building your next great idea with confidence.
            </p>
            
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Button size="xl" className="group">
                Get Started
                <ArrowRight className="w-5 h-5 transition-transform group-hover:translate-x-1" />
              </Button>
              <Button variant="outline" size="xl">
                Learn More
              </Button>
            </div>
          </div>

          {/* Feature Cards */}
          <div className="grid md:grid-cols-3 gap-6 mt-24 max-w-5xl mx-auto">
            <FeatureCard
              icon={<Zap className="w-6 h-6" />}
              title="Lightning Fast"
              description="Built on Vite for instant hot module replacement and blazing fast builds."
              delay="0s"
            />
            <FeatureCard
              icon={<Shield className="w-6 h-6" />}
              title="Type Safe"
              description="Full TypeScript support out of the box for safer, more reliable code."
              delay="0.1s"
            />
            <FeatureCard
              icon={<Sparkles className="w-6 h-6" />}
              title="Beautiful UI"
              description="Pre-configured with Tailwind CSS and shadcn/ui for stunning interfaces."
              delay="0.2s"
            />
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-border py-8">
        <div className="container mx-auto px-6 text-center text-sm text-muted-foreground">
          <p>Built with React, Tailwind CSS, and shadcn/ui</p>
        </div>
      </footer>
    </div>
  );
};

interface FeatureCardProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  delay: string;
}

const FeatureCard = ({ icon, title, description, delay }: FeatureCardProps) => {
  return (
    <div 
      className="group p-6 rounded-2xl bg-card border border-border shadow-card hover:shadow-card-hover transition-all duration-300 hover:-translate-y-1 animate-scale-in"
      style={{ animationDelay: delay }}
    >
      <div className="w-12 h-12 rounded-xl bg-secondary flex items-center justify-center text-foreground mb-4 group-hover:bg-accent group-hover:text-accent-foreground transition-colors duration-300">
        {icon}
      </div>
      <h3 className="font-display font-semibold text-lg text-foreground mb-2">{title}</h3>
      <p className="text-muted-foreground text-sm leading-relaxed">{description}</p>
    </div>
  );
};

export default Index;

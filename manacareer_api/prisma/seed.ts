import * as dotenv from 'dotenv';
dotenv.config();

import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const data = [
  {
    title: 'Frontend Engineer Intern',
    org: 'Orbit Cloud Systems',
    type: 'internships',
    district: 'Warangal',
    location: 'Warangal IT Tower',
    money: '₹15,000/mo',
    deadline: '3 days left',
    urgent: true,
    about: "Build and ship UI for Orbit's logistics dashboard used by clients across South India.",
    eligibility: ['2nd year and above, any branch', 'Comfortable with HTML/CSS/JS basics', 'Can commit 20 hrs/week'],
    applyInfo: 'Apply with your resume — no cover letter needed.',
  },
  {
    title: 'Associate Software Engineer',
    org: 'Nexora Technologies',
    type: 'jobs',
    district: 'Karimnagar',
    location: 'Karimnagar IT Park',
    money: '₹4.2 LPA',
    deadline: '6 days left',
    urgent: false,
    about: "Full-time role on Nexora's core platform team, building APIs for their fintech clients.",
    eligibility: ['2026 B.Tech/B.E. graduates', 'Basic SQL and one OOP language'],
    applyInfo: 'Online assessment, then a single in-person interview.',
  },
  {
    title: 'Smart Agri Hackathon 2026',
    org: 'TASK x WE-HUB',
    type: 'hackathons',
    district: 'Hyderabad',
    location: 'T-Hub, Hyderabad',
    money: '₹1,00,000 prize pool',
    deadline: '10 days left',
    urgent: false,
    about: "A 48-hour build sprint on tools for Telangana's farmers.",
    eligibility: ['Teams of 2–4 students', 'At least one member from a Telangana college'],
    applyInfo: 'Register your team, then submit a one-page concept note.',
  },
];

async function main() {
  for (const opp of data) {
    await prisma.opportunity.create({ data: opp });
  }
  console.log('Seeded 3 opportunities');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());